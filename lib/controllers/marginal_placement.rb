
require('aurita/plugin_controller')

module Aurita
module Plugins
module Publish

  class Marginal_Placement_Controller < Plugin_Controller
  
    def perform_add
      section    = param(:section) 
      placements = param("marginal_placements_#{section}")

      Marginal_Placement.delete { |mp|
        mp.where((mp.page_id == param(:page_id)) & (mp.section == section))
      }
      
      pos = 0
      placements.each { |marginal_id|
        Marginal_Placement.create(:page_id     => param(:page_id), 
                                  :marginal_id => marginal_id, 
                                  :position    => pos, 
                                  :section     => section)
        pos += 1
      }
    end

  end

end
end
end

