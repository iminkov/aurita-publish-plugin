
require('aurita/plugin_controller')
Aurita.import_plugin_model :publish, :page
Aurita.import_plugin_model :publish, :page_element
Aurita.import_plugin_module :wiki, :gui, :article_selection_field
Aurita.import_plugin_controller :wiki, :article

module Aurita
module Plugins
module Publish

  class Page_Controller < Plugin_Controller

    guard(:add, :perform_add) { |c|
      Aurita.user.is_registered? 
    }

    guard(:update, :perform_update, :delete, :perform_delete) { |c|
      Aurita.user.may_edit_content?(c.load_instance)
    }

    def show
      page     = load_instance()
      elements = page.elements.map { |p|
        if p.kind_of?(Wiki::Article) then
          render_controller(Wiki::Article_Controller, :show, :article_id => p.article_id)
        end
      }

      if Aurita.user.may_edit_content?(page) then
        GUI::Page.new { 
          HTML.div.button_bar { 
            GUI::Text_Button.new(:onclick => link_to(:controller => 'Publish::Page_Element', 
                                                     :action     => :add_article, 
                                                     :page_id    => page.page_id, 
                                                     :element    => :form_section)) { 
              tl(:add_article) 
            } 
          } +
          HTML.div(:id => :form_section) { } + 
          elements
        }
      else
        elements
      end
    end

    def add
    end

    def update
    end

    def hierarchy_entry_type
      { 
        :name       => 'PAGE', 
        :label      => tl(:page) 
      }
    end
    def hierarchy_entry(params)
      entry = params[:entry]
      if entry.attr[:type] == 'PAGE' then
        article_id = entry.interface.split('=')[-1]
        article = Article.load(:article_id => article_id)
      end
      return ''
    end
    def perform_add_hierarchy_entry(params)
      param[:tags] = '%page'
      page = perform_add()

      { :content => page }
    end

  end

end
end
end

