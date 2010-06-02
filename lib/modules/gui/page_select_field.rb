
require('aurita-gui/form/select_field')

module Aurita
module Plugins
module Publish
module GUI

  class Page_Select_Field < Aurita::GUI::Select_Field
  include Aurita::GUI
  include Aurita::GUI::I18N_Helpers

    def initialize(params={})
      entries   = []
      Hierarchy.find(:all).entities.each { |hierarchy|
        entries += hierarchy.concrete_entries
      }
      map       = Hierarchy_Map_Iterator.new(entries)
      options   = [ tl(:select_choose) ]
      page_ids  = [ '' ]
      map.each_with_level { |page,level|
        label  = ' '
        level.times { label << '&nbsp;&nbsp;' }
        label    << page.hierarchy_label
        options  << label
        page_ids << page.page_id.to_s
      }
      options.fields = page_ids

      params[:options] = options
      
      super(params)
    end

  end

end
end
end
end

