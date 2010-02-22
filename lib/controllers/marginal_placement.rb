
module Aurita
module Plugins
module Publish

  class Marginal_Placement_Controller < Plugin_Controller
  
    def perform_add
      if param(:section) == 'left' then
        placements = param(:marginal_placements_left)
        section    = 'left'
      elsif param(:section) == 'right' then
        placements = param(:marginal_placements_right)
        section    = 'right'
      end

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

