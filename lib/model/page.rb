
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
  end

end
end
end

