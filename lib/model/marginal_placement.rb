
require('aurita')
Aurita.import_plugin_model :publish, :marginal

module Aurita
module Plugins
module Publish

  class Marginal_Placement < Aurita::Model
    table :marginal_placement, :public
    primary_key :marginal_placement_id, :marginal_placement_id_seq

    has_a Marginal, :marginal_id

#    validates(:section) { |v|
#      ['left','right','bottom'].include?(v.to_s)
#    }

    def marginal
      Marginal.get(marginal_id)
    end
  end

end
end
end

