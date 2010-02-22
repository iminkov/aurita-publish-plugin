
require('aurita/plugin_controller')
require('aurita-gui/form/text_field')
Aurita.import_plugin_model :publish, :marginal
Aurita.import_plugin_model :wiki, :article
Aurita.import_plugin_model :wiki, :media_asset
Aurita.import_plugin_model :publish, :marginal_placement
Aurita.import_plugin_module :wiki, 'gui/article_selection_field'

module Aurita
module Plugins
module Publish

  class Marginal_Controller < Plugin_Controller

    def form_groups
      [
        Marginal.header, 
        :article
      ]
    end

    def add 
      form = add_form()
      form.add(Aurita::GUI::Text_Field.new(:name => Marginal.header, :maxlength => 30, :label => tl(:header)))
      form.add(Aurita::Plugins::Wiki::GUI::Article_Selection_Field.new(:name  => :article, 
                                                                       :key   => :article_id, 
                                                                       :label => tl(:article), 
                                                                       :id    => :marginal_article_id))
      element = decorate_form(form) 
      element = Aurita::GUI::Page.new(:header => tl(:add_marginal)) { element } if param(:element) == 'app_main_content'
      element
    end

    def perform_add
      super()
      redirect_to(:list)
    end

    def selection_box
      buttons = []
      if Aurita.user.may(:edit_marginals) then
        add_marginal = HTML.a(:class   => :icon, 
                              :onclick => link_to(:add)) { 
          icon_tag(:article_add) + tl(:add_marginal) 
        } 
        buttons << add_marginal
        list_marginals = HTML.a(:class   => :icon, 
                                :onclick => link_to(:list)) { 
          icon_tag(:article_edit) + tl(:edit_marginals) 
        } 
        buttons << list_marginals
      end

      tools        = Box.new(:class => :topic, :id => :marginal_selection_box)
      tools.header = tl(:marginals)
      tools.body   = HTML.div { buttons } + HTML.div(:id => :marginal_selection_list) { selection_box_body }
      tools
    end
    
    def page_placements()
      return unless param(:page_id)
      placements = {} 
      Marginal_Placement.all_with(:page_id.is(param(:page_id))).each { |p|
        placements << p.marginal_id
      }
      thumbs = Marginal.find(:all).entities.map { |marginal|
        thumb = Wiki::GUI::Media_Asset_Thumbnail.new(marginal, :size => :tiny)
        if placements[marginal.marginal_id] then
          thumb
        else
          HTML.div(:onclick => "Aurita.Marginal.place(#{marginal.marginal_id}, #{param(:page_id)});") {
            thumb
          }
        end
      }
    end

    def selection_box_body 
      return unless param(:page_id)
      place_marginals = HTML.a(:class   => :icon, 
                               :onclick => link_to(:placement_editor, :page_id => param(:page_id))) { 
        icon_tag(:context_reorder) + tl(:place_marginals) 
      } 
      return HTML.div { place_marginals }
      
      HTML.ul { 
        Marginal.find(:all).entities.map { |marginal|
           HTML.li { link_to(marginal, :action => :update) { marginal.header } }
        }
      }
    end

    def list
      HTML.ul { 
        Marginal.all.entities.map { |m|
          HTML.li { m.header }
        }
      }
    end

    def show
    end

    def placement_editor
      exec_js("Aurita.Publish.init_marginal_placement_editor(#{param(:page_id)});")
      
      placements_left  = []
      placements_right = []
      placement_ids    = [0]
      Marginal_Placement.all_with(:page_id => param(:page_id)).sort_by(:position, :desc).each { |mp|
        placement_ids << mp.marginal_id
        images = Wiki::Article.get(mp.marginal.article_id).media_assets
        image  = images[0] if images
        if image then
          elem = HTML.li(:id => "placement_#{mp.marginal_id}") { 
            HTML.div.header { mp.marginal.header } + 
            HTML.div.marginal_image { image.icon(:preview) } 
          } 
          placements_left  << elem if mp.section == 'left'
          placements_right << elem if mp.section == 'right'
        end
      }
      
      marginals = Marginal.select { |m|
        m.where(Marginal.marginal_id.not_in(placement_ids))
      }.to_a.map { |m|
        images = Wiki::Article.get(m.article_id).media_assets
        image  = images[0] if images
        if image then
          HTML.li(:id => "placement_#{m.marginal_id}") { 
            HTML.div.header { m.header } + 
            HTML.div.marginal_image { image.icon(:preview) } 
          }
        end
      }
      
      Aurita::GUI::Page.new(:header => tl(:marginal_placements)) { 
        HTML.div.marginals { 
          HTML.ul(:id => :place_marginal_selection_list) { marginals } +
          HTML.div(:style => 'clear: both;') { } 
        } + 
        HTML.div.marginal_placement_editor { 
          HTML.ul(:id => :marginal_placements_left) { placements_left } + 
          HTML.ul(:id => :marginal_placements_right) { placements_right } +
          HTML.div(:style => 'clear: both;') { } 
        }
      } 
    end

  end

end
end
end

