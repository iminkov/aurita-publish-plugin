
require('aurita/model')

module Aurita
module Plugins
module Publish

  class Public_Comment < Aurita::Model

    table :public_comment, :public
    primary_key :public_comment_id, :public_comment_id_seq

    has_a Aurita::Main::Content, :content_id

  end

end # Publish
end # Plugins

module Main

  class Content
  include Aurita::Plugins

    def public_comments
      @comments ||= Publish::Public_Comment.all_with(:content_id => content_id).sort_by(:timestamp_created, :asc).entities
      @comments
    end
    def validated_comments
      @comments ||= Publish::Public_Comment.all_with(:validated  => true, 
                                                     :content_id => content_id).sort_by(:timestamp_created, :asc).entities
      @comments
    end
    def unvalidated_comments
      @comments ||= Publish::Public_Comment.all_with(:validated  => false, 
                                                     :content_id => content_id).sort_by(:timestamp_created, :asc).entities
      @comments
    end

    def allows_comments? 
      allow_public_comments()
    end

  end
  
end
end

