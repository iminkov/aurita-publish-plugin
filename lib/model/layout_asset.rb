
require('aurita/model')
Aurita.import_plugin_model :wiki, :asset

module Aurita
module Plugins
module Publish

  class Layout_Asset < Aurita::Plugins::Wiki::Asset
    table :article_layout_asset, :public
    primary_key :article_layout_asset_id, :article_layout_asset_id_seq
    
  end

end
end
end

