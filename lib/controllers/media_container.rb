
require('aurita')
Aurita.import_plugin_controller :wiki, :media_container

module Aurita
module Plugins
module Publish

  class Media_Container_Controller < Aurita::Plugins::Wiki::Media_Container_Controller

    guard_interface(:set_position) { 
      mc = load_instance()
      Aurita.user.may_edit_content?(mc.article)
    }

    def article_partial(params={})
      article         = params[:article]
      media_container = params[:part]
      GUI::Media_Container_Partial.new(media_container)
    end


    def set_position
      mc = load_instance()
      mc.vertical = param(:vertical)
      mc.commit
    end

  end

end
end
end

