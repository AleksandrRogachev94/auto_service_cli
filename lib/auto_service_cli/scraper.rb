class AutoServiceCLI::Scraper
  attr_reader :url, :doc, :sort_type

  def initialize(year)
    sort_type = "default"
    @url = "#{AutoServiceCLI::URL_WORLD_RANKIGS_TEMPLATE}#{year}"
    @doc = Nokogiri::HTML(open("http://www.topuniversities.com/university-rankings/university-subject-rankings/2016/engineering-chemical"))
    binding.pry
    #year = Date.today.strftime("%Y%m")
  end

  def scrape_centers
    raise InvalidURL if @doc == nil
    universities = self.doc.css(".uni a").text
  end
end

http://www.yellowpages.com/search?search_terms=auto%20service&geo_location_terms=17401&s=default
