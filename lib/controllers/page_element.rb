
require('aurita/plugin_controller')
Aurita.import_plugin_model :publish, :page
Aurita.import_plugin_model :publish, :page_element
Aurita.import_plugin_module :wiki, :gui, :article_selection_field

module Aurita
module Plugins
module Publish

  class Page_Element_Controller < Plugin_Controller

    def add_article
      form = add_form
      form[:action].value = :perform_add_article

      form.add(GUI::Hidden_Field.new(:name => :page_id, :value => param(:page_id)))
      form.add(Wiki::GUI::Article_Selection_Field.new(:name  => :article, 
                                                      :label => tl(:find_article), 
                                                      :id    => :article_id_selection))
      form.fields = [ :article, :page_id ]

      form = decorate_form(form)
      return form unless param(:element) == 'app_main_content'

      GUI::Page.new(:header => tl(:edit_page)) { 
        form
      }
    end

    def perform_add_article
      param[:position] = 0
      perform_add()
      page = Publish::Page.get(param(:page_id))
      redirect_to(page) if page
    end

  end

end
end
end

