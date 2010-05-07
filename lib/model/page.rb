
require('aurita/model')
Aurita::Main.import_model :content
Aurita.import_plugin_model :publish, :page_metadata

module Aurita
module Plugins
module Publish

  include Aurita::Main

  class Page < Content
    table :page, :public
    primary_key :page_id, :page_id_seq

    is_a Content, :content_id
    has_a Page_Metadata, :page_metadata_id

    def allows_comments?
      allow_comments
    end
    
    def elements(params={})
      amount = params[:amount]
      # We expect rather few page elements, while 
      # there are many concrete classes for Content, 
      # so we use lazy polymorphism. 

      @elements ||= Content.select { |c|
        c.limit(amount) if amount
        c.join(Page_Element).using(:content_id) { |cid| 
          cid.where(Page_Element.page_id == page_id)
          cid.order_by(Page_Element.page_element_id, :desc)
        }
      }.to_a.map { |c| c.concrete_instance }

      @elements
    end

    def hierarchy_entry
      Hierarchy_Entry.find(1).with(:content_id => content_id).entity
    end

    def title
      hierarchy_entry.label
    end

    def hierarchy_path(rec_path=[])
      if rec_path.length == 0 then
        e = Hierarchy_Entry.find(1).with(:content_id => content_id).entity
        rec_path << { :entry => e, 
                      :page  => self }
        return hierarchy_path(rec_path)
      else
        parent_heid = rec_path[-1][:entry].hierarchy_entry_id_parent 
        if parent_heid == 0 then
          top = Hierarchy.get(rec_path[-1][:entry].hierarchy_id)
          if !top.locked then
            rec_path << { :entry => top, :page => false }
          end
          return rec_path 
        end
        e    = Hierarchy_Entry.find(1).with(:hierarchy_entry_id => parent_heid).entity
        page = false
        if e.content_id then
          page = Page.find(1).with(Page.content_id == e.content_id).entity
        end
        rec_path << { :entry => e, :page => page }
        return hierarchy_path(rec_path)
      end
    end

    def metadata
      meta = Page_Metadata.find(1).with(:page_id => page_id).entity
      return meta if meta
      
      parts       = elements()
      description = parts.first.teaser
      keywords    = parts.map { |p| p.tags }.flatten

      return Mock_Object.new(:description => description, 
                             :keywords    => keywords)
    end

    def parent_id
      @parent_id ||= self.class.select_values(:page_id) { |p|
        p.where(Page.content_id.in { 
          Hierarchy_Entry.select(:content_id) { |pid|
            pid.where(Hierarchy_Entry.hierarchy_entry_id == Hierarchy_Entry.select(:hierarchy_entry_id_parent) { |epid|
              epid.where(Hierarchy_Entry.content_id == content_id)
            })
            pid.limit(1)
          }
        })
      }.to_a.flatten.first.to_i
      @parent_id ||= 0
      @parent_id
    end

    def hierarchy_label
      Hierarchy_Entry.select_values(:label) { |l|
        l.where(:content_id => content_id)
      }.to_a
    end

  end

end
end
end

