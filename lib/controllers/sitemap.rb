
require('aurita/plugin_controller')
Aurita.import_plugin_module :publish, :sitemap

module Aurita
module Plugins
module Publish 

  class Sitemap_Controller < Plugin_Controller

    def show
      use_decorator :none

      pages = Publish::Page.find(:all).entities
      puts Sitemap.new(pages).string
    end

  end

end
end
end
