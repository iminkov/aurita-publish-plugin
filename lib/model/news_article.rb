
require('aurita')
Aurita.import_plugin_model :wiki, :article

module Aurita
module Plugins
module Publish

  class News_Article < Wiki::Article
    table :news_article, :public
    primary_key :news_article, :news_article_id_seq

    is_a Wiki::Article, :article_id
  end

end
end
end

