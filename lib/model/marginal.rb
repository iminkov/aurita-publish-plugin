
require('aurita/model')

module Aurita
module Plugins
module Publish
  
  class Marginal < Aurita::Model 
    table :marginal, :public
    primary_key :marginal_id, :marginal_id_seq

    is_polymorphic :concrete_model

    validates(:header, :maxlength => 30) 
  end

end
end
end

