
require('aurita/plugin_controller')
require('aurita-gui/form/select_field')
Aurita.import_module :gui, :text_button
Aurita.import_plugin_model :publish, :page
Aurita.import_plugin_model :publish, :page_element
Aurita.import_plugin_module :wiki, :gui, :article_selection_field
Aurita.import_plugin_module :publish, :gui, :page_selection_field
Aurita.import_plugin_controller :wiki, :article
Aurita.import_plugin_controller :wiki, :media_asset

module Aurita
module Plugins
module Publish

  class Page_Controller < Plugin_Controller
    include Aurita::GUI

    def form_groups
      [
       Page.title,
       Content.tags, 
       Category.category_id, 
       Page.meta_keywords, 
       Page.meta_description, 
       Page.allow_comments
      ]
    end

    guard(:add, :perform_add) { |c|
      Aurita.user.is_registered? 
    }

    guard(:update, :perform_update, :delete, :perform_delete) { |c|
      Aurita.user.may_edit_content?(c.load_instance)
    }

    def text_asset_link_field
      entries   = Hierarchy.find(1).entity.concrete_entries
      map       = Hierarchy_Map_Iterator.new(entries)
      options   = []
      page_ids  = []
      map.each_with_level { |page,level|
        label  = ' '
        level.times { label << '&nbsp;&nbsp;' }
        label    << page.hierarchy_label
        options  << label
        page_ids << page.page_id.to_s
      }
      options.fields = page_ids
      Select_Field.new(:name     => :page_id, 
                       :label    => tl(:link_to_page), 
                       :options  => options, 
                       :onchange => "Aurita.Publish.link_page(this);")
    end

    def show
      
      page = load_instance()
      return unless page
      return unless Aurita.user.may_edit_content?(page) 

      exec_js("Aurita.Publish.onload_page(#{page.page_id});")
      exec_js("Aurita.Advert.onload_page(#{page.page_id});") # TODO: Move this to Advert plugin

      if page.special then
        message_box = HTML.div(:class => [:message_box, :notice]) { 
          tl(:page_cannot_be_edited)
        }
        return message_box
      end

      elements = page.elements.map { |p|
        if p.kind_of?(Wiki::Article) then
          Aurita::GUI::Text_Button.new(:class   => :remove_article_button, 
                                       :onclick => link_to(:controller => 'Publish::Page_Element', 
                                                           :action     => :perform_delete, 
                                                           :page_id    => page.page_id, 
                                                           :content_id => p.content_id)) { tl(:remove_article) } + 
          render_controller(Wiki::Article_Controller, :show, :article_id => p.article_id)
        end
      }

      footer = plugin_get(Hook.publish.page.show.footer, :content => page)
      elements += footer

      if Aurita.user.may_edit_content?(page) then
        Aurita::GUI::Page.new { 
          HTML.div.button_bar { 
            Aurita::GUI::Text_Button.new(:onclick => link_to(:controller => 'Publish::Page_Element', 
                                                             :action     => :add_article, 
                                                             :page_id    => page.page_id, 
                                                             :element    => :form_section)) { 
              tl(:add_article) 
            } + 
            Aurita::GUI::Text_Button.new(:onclick => link_to(:controller => 'Publish::Page', 
                                                             :action     => :update, 
                                                             :page_id    => page.page_id), 
                                         :icon => 'edit_button.gif') { 
              tl(:edit_page_properties) 
            } 
          } +
          HTML.div(:id => :form_section) { } + 
          elements
        }
      else
        elements
      end
    end

    def background_selection_box
      box         = Box.new(:class => :topic, :id => :background_selection_box)
      box.header  = tl(:background)
      box.body    = background_selection_box_body
      box
    end

    def background_selection_box_body
      page = load_instance()
      return unless page

      backgrounds = Wiki::Media_Asset.all_with((Wiki::Media_Asset.deleted == 'f') & 
                                               (Wiki::Media_Asset.media_folder_id == 220)).map { |b|
        highlight_class = nil
        if b.media_asset_id == page.bg_media_asset_id then
          highlight_class = :highlighted
        end
        HTML.div(:class => highlight_class, 
                 :style => "float: left;  
                            margin-right: 1px; margin-bottom: 1px; 
                            padding: 1px; ") { 
          link_to(:perform_set_background, 
                  :element        => :dispatcher, 
                  :media_asset_id => b.media_asset_id, 
                  :page_id        => param(:page_id)) {
            HTML.img(:src => "/aurita/assets/small/asset_#{b.media_asset_id}.jpg")
          }
        }
      }
      HTML.div { backgrounds }
    end

    def perform_set_background
      page = load_instance()
      page.bg_media_asset_id = param(:media_asset_id)
      page.commit
      redirect(:element => :background_selection_box_body, 
               :to      => :background_selection_box_body, 
               :page_id => param(:page_id))
    end

    def add
      super()
    end

    def update
      page     = load_instance()
      form     = update_form()
      category = Category_Selection_List_Field.new()
      category.value = page.category_ids
      form.add(category)

      form[Content.tags] = Tag_Autocomplete_Field.new(:name => Content.tags.to_s, :label => tl(:tags), :value => page.tags)
      form[Content.tags].required!
      exec_js('Aurita.Main.init_autocomplete_tags();')

      if Aurita.user.is_admin? or page.user_group_id == Aurita.user.user_group_id then 
        form.fields << Content.locked.to_s
        is_locked   = Boolean_Radio_Field.new(:name => Content.locked, 
                                              :label => tl('public--content--locked'), 
                                              :value => page.locked)
        form.add(is_locked)
      end

      render_form(form)
    end

    def perform_update
      super()
      redirect(:to => :show, :page_id => param(:page_id))
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

