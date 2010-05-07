
require('aurita/model')
Aurita.import_plugin_model :publish, :page

module Aurita
module Plugins
module Publish

  class Page_Comment < Aurita::Model

    table :page_comment, :public
    primary_key :page_comment_id, :page_comment_id_seq

    has_a Page, :page_id

  end

  class Page < Content
    def comments
      @comments ||= Page_Comment.all_with(:page_id => page_id).sort_by(:timestamp_created, :asc).entities
      @comments
    end
    def validated_comments
      @comments ||= Page_Comment.all_with(:validated => true, 
                                          :page_id   => page_id).sort_by(:timestamp_created, :asc).entities
      @comments
    end
    def unvalidated_comments
      @comments ||= Page_Comment.all_with(:validated => false, 
                                          :page_id   => page_id).sort_by(:timestamp_created, :asc).entities
      @comments
    end
  end
  
end
end
end

