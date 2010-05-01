
require('aurita/model')

module Aurita
module Plugins
module Publish
  
  class Marginal < Aurita::Model 
    table :marginal, :public
    primary_key :marginal_id, :marginal_id_seq

    is_polymorphic :concrete_model

    def article
      Wiki::Article.get(article_id)
    end

    add_output_filter(:media_asset_ids) { |v|
      v.squeeze(',')[1..-2].split(',')
    }

    def images
      if !@images then
        @images = media_asset_ids.map { |mid| Wiki::Media_Asset.get(mid) }
        if !media_asset_ids.first then
          @images = article.media_assets
        end
      end
      return @images
    end

  end

end
end
end

