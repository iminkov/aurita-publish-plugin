
require('aurita')
Aurita.import_plugin_controller :wiki, :media_container
Aurita.import_plugin_module :publish, 'gui/media_container_partial'

module Aurita
module Plugins
module Publish

  class Media_Container_Controller < Aurita::Plugins::Wiki::Media_Container_Controller

    use_model Aurita::Plugins::Wiki::Media_Container

    guard_interface(:set_position) { |controller|
      mc = controller.load_instance()
      Aurita.user.may_edit_content?(mc.article)
    }

    def article_partial(params={})
      article         = params[:article]
      media_container = params[:part]
      GUI::Media_Container_Partial.new(media_container)
    end

    def set_position
      mc = load_instance()
      mc.position = param(:position)
      mc.commit
    end

  end

end
end
end

