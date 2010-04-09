
require('aurita')
Aurita.import_module :gui, :datetime_helpers

module Aurita
module Plugins
module Publish

  class Sitemap
  include Aurita::GUI::Datetime_Helpers

    def initialize(pages)
      @pages = pages
    end

    def string
      s = <<EOS
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9
                            http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd">
EOS
      @pages.each { |p|
        article = p.elements(:amount => 1).first
        title   = ''
        if article then
          title = article.title
          ['.',',','-','!','?',' ',':'].each { |c| title.gsub!(c,'_') }
          title.squeeze!('_')
        end
        s << "
          <url>
            <loc>http://#{Aurita.project.host}/aurita/Publish::Page/#{p.page_id}/show/#{title}</loc>
            <lastmod>#{datetime_string(p.changed, "%Y-%m-%d")}</lastmod>
            <changefreq>daily</changefreq>
            <priority>0.8</priority>
          </url>"
      }
      s += "\n</urlset>"
    end

  end

end
end
end

