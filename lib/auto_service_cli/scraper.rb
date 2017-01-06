class AutoServiceCLI::Scraper
  attr_reader :doc, :sort_type, :zip

  def initialize(zip, sort_type = "default")
    @sort_type = sort_type
    @zip = zip
    @doc = Nokogiri::HTML(open(get_url))
  end

  def get_url
    raise InvalidURLData, "Invalid input data (zip or sort type)!!!" unless valid_url_data?
    AutoServiceCLI::URL_TEMPLATE + "#{self.zip}&s=#{self.sort_type}"
  end

  def valid_url_data?
    (self.sort_type == "default" || self.sort_type == "distance" || self.sort_type == "rating" || self.sort_type == "name") && self.zip > 0
  end

  def scrape_centers
    raise InvalidPage "Invalid page!!!" if self.doc == nil
    centers = self.doc.css(".organic .result .info")
    centers.each do |center|
      clCenter = AutoServiceCLI::ServiceCenter.create(center.css(".n a").text)
      clCenter.url = AutoServiceCLI::URL_BASE + center.css(".n a").attr("href").value.to_s
      puts "#{clCenter.name} #{clCenter.url}"
    end
  end
end
