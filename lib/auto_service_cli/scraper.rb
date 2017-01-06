class AutoServiceCLI::Scraper
  attr_reader :doc, :sort_type, :zip

  def initialize(zip)
    @sort_type = "default"
    @zip = zip
    binding.pry
    #@url = "#{AutoServiceCLI::URL_WORLD_RANKIGS_TEMPLATE}#{year}"
    #@doc = Nokogiri::HTML(open("http://www.topuniversities.com/university-rankings/university-subject-rankings/2016/engineering-chemical"))
    #binding.pry
  end

  def get_url
    raise InvalidURLData, "Invalid input data (zip or sort type)!!!" unless valid_url_data?
    AutoServiceCLI::URL_TEMPLATE << "#{@zip}&s=#{sort_type}"
    #http://www.yellowpages.com/search?search_terms=auto%20service&geo_location_terms=17401&s=default
  end

  def valid_url_data?
    (sort_type == "default" || sort_type == "distance" || sort_type == "rating" || sort_type == "name") && zip > 0
  end

  def scrape_centers
    raise InvalidURL if @doc == nil
    universities = self.doc.css(".uni a").text
  end
end
