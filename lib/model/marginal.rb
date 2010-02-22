
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

  end

end
end
end

