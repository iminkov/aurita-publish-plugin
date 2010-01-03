
require('aurita/model')

module Aurita
module Plugins
module Publish

  class Page_Element < Aurita::Model
    table :page_element, :public
    primary_key :page_element_id, :page_element_id_seq
    
  end

end
end
end

