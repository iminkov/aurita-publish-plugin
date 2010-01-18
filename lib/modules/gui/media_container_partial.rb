
require('aurita')
require('aurita-gui/element')
Aurita.import_plugin_module :wiki, 'gui/media_container_partial'

module Aurita
module Plugins
module Publish
module GUI

  class Media_Container_Positioning_Button < DelegateClass(Aurita::GUI::Element)
  include Aurita::GUI
  include Aurita::GUI::Link_Helpers

    def initialize(media_container)
      mcid    = media_container.media_container_id
      element = false

      action  = "Publish::Media_Container/set_position/media_container_id=#{mcid}&position"
      icon_l  = '/aurita/images/icons/media_container_l.gif'
      icon_r  = '/aurita/images/icons/media_container_r.gif'
      icon_h  = '/aurita/images/icons/media_container_h.gif'
      but_l   = "media_container_pos_button_#{mcid}_l"
      but_r   = "media_container_pos_button_#{mcid}_r"
      but_h   = "media_container_pos_button_#{mcid}_h"

      case media_container.position
      when 'h':
        hl_h = :highlighted
      when 'l':
        hl_l = :highlighted
      when 'r':
        hl_r = :highlighted
      end

      btn_h = HTML.div(:id => but_h, :class => [ :context_menu_button, hl_h ], 
                       :onclick => "Aurita.load({ element: 'dispatcher', action: '#{action}=h' }); 
                                    $('#{but_r}').removeClassName('highlighted'); 
                                    $('#{but_l}').removeClassName('highlighted'); 
                                    $('#{but_h}').addClassName('highlighted');") { 
        HTML.img(:src => icon_h)
      } 
      btn_l = HTML.div(:id => but_l, :class => [ :context_menu_button, hl_l ], 
                       :onclick => "Aurita.load({ element: 'dispatcher', action: '#{action}=l' }); 
                                    $('#{but_h}').removeClassName('highlighted'); 
                                    $('#{but_r}').removeClassName('highlighted'); 
                                    $('#{but_l}').addClassName('highlighted');") { 
        HTML.img(:src => icon_l)
      } 
      btn_r = HTML.div(:id => but_r, :class => [ :context_menu_button, hl_r ], 
                       :onclick => "Aurita.load({ element: 'dispatcher', action: '#{action}=r' }); 
                                    $('#{but_h}').removeClassName('highlighted'); 
                                    $('#{but_l}').removeClassName('highlighted'); 
                                    $('#{but_r}').addClassName('highlighted');") { 
        HTML.img(:src => icon_r)
      } 
      super(HTML.div { btn_h + btn_l + btn_r })
    end
  end

  class Media_Container_Partial < Aurita::Plugins::Wiki::GUI::Media_Container_Partial
    def context_buttons
      Media_Container_Positioning_Button.new(@media_container)
    end
  end

end
end
end
end

