
require('aurita/controller')

module Aurita
module Plugins
module Publish

  class News_Article_Controller < Aurita::Plugin_Controller
    
    def form_groups
      [
        Article.title, 
        Article.header, 
        Content.tags, 
        Category.category_id, 
        News_Article.publish_at, 
        News_Article.is_event
      ]
    end

    def toolbar_buttons
      return unless Aurita.user.may(:publish_news)

      
    end
    

  end

end
end
end

