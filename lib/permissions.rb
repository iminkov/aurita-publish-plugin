
require('aurita/plugin')

module Aurita
module Plugins
module Publish


  # Usage: 
  #
  #  plugin_get(Hook.right_column)
  #
  class Permissions < Aurita::Plugin::Manifest

    register_permission(:publish_news, 
                        :type    => :bool, 
                        :default => true)

    register_permission(:edit_marginals, 
                        :type    => :bool, 
                        :default => true)

  end

end
end
end

