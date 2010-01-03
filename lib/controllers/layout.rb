
require('aurita/plugin_controller')
Aurita.import_plugin_model :publish, :layout
Aurita.import_plugin_module :wiki, :article_hierarchy_default_decorator

module Aurita
module Plugins
module Publish

  class Layout_Controller < Plugin_Controller

    def add
      super()
    end

    def article_partial_type
      { 
        :model  => Layout, 
        :label  => :add_layout_partial, 
        :action => :add
      }
    end

    def article_partial(params={})
      article    = params[:article]
      layout     = params[:part]
      viewparams = params[:viewparams]

      elements = []
      layout.assets.each_with_index { |asset,idx|
        asset = asset.concrete_instance
        elements << HTML.div(:style => "width: #{width}") { 
          Aurita::Plugins::Wiki::Article_Hierarchy_Default_Decorator.new(article).decorate_part(asset)
        }
      }

      HTML.div.article_partial(:id => "layout_#{layout.layout_id}") { 
        HTML.div.layout { elements } 
      }
    end

  end

end
end
end

