
require('aurita/model')

module Aurita
module Plugins
module Publish

  class Page_Metadata < Aurita::Model
    table :page_metadata, :public
    primary_key :page_metadata, :page_metadata_id_seq
  end

end
end
end

