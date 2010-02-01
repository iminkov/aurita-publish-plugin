
require('aurita/model')
Aurita::Main.import_model :content

module Aurita
module Plugins
module Publish

  include Aurita::Main

  class Page < Content
    table :page, :public
    primary_key :page_id, :page_id_seq

    is_a Content, :content_id
    
    def elements
      # We expect rather few page elements, while 
      # there are many concrete classes for Content, 
      # so we use lazy polymorphism. 

      @elements ||= Content.select { |c|
        c.where(c.content_id.in(Page_Element.select(:content_id) { |cid|
          cid.where(Page_Element.page_id == page_id)
        }))
      }.to_a.map { |c| c.concrete_instance }

      @elements
    end

    def hierarchy_path(rec_path=[])
   #  return [] if special

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

  end

end
end
end

