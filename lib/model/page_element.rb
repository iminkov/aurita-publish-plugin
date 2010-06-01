
require('aurita/model')
Aurita::Main.import_model :content
Aurita.import_plugin_model :wiki, :media_asset

module Aurita
module Plugins
module Publish

  class Page_Element < Aurita::Model
    table :page_element, :public
    primary_key :page_element_id, :page_element_id_seq
    
  end

end # Publish

module Wiki

  class Article < Aurita::Main::Content
    
    def teaser_text(length=280)
      ta = text_assets.first
      if ta then
        return ta.text.to_s.gsub(/<(\/)?([^>]+)(\/)?>/,'').gsub('&nbsp;',' ').gsub(/<img([^>]+)>/,'').squeeze(' ')[0..length].split(' ')[0..-2].join(' ') 
      end
      return ''
    end

  end

  class Media_Asset < Wiki::Asset

    add_output_filter(:description) { |v|
      v.to_s.gsub('"','&quot;')
    }

    def teaser_text(length=280)
      description.to_s.squeeze(' ')[0..length].split(' ')[0..-2].join(' ')
    end

  end

end # Wiki
end # Plugins
end # Aurita

