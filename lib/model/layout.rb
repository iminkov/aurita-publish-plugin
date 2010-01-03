
require('aurita/model')

Aurita.import_plugin_model :publish, :layout_asset

module Aurita
module Plugins
module Publish

  class Layout < Aurita::Model
    table :article_layout, :public
    primary_key :article_layout_id, :article_layout_id_seq
    
    def assets
      @assets ||= Wiki::Assets.select { |a|
        a.where(a.asset_id.in(Layout_Asset.select(:asset_id) { |aid|
          aid.where(Layout_Asset.article_layout_id == article_layout_id)
          aid.order_by(:position, :desc)
        }))
      }.to_a

      @assets
    end

  end

end
end
end

