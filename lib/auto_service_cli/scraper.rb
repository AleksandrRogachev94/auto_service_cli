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

  def external_link?
    temp_url.include?("www.") || temp_url.include?("http://") || temp_url.include?("https://")
  end

  def scrape_centers
    raise InvalidPage, "Invalid page!!!" if self.doc == nil
    centers = self.doc.css(".organic .result .info")
    centers.each do |center|
      clCenter = AutoServiceCLI::ServiceCenter.create(center.css(".n a").text)
      temp_url = center.css(".n a").attr("href").value

      if external_link?
        clCenter.ext_url = temp_url
      else
        clCenter.int_url = AutoServiceCLI::URL_BASE + temp_url
      end

      clCenter.main_category = center.css(".info-secondary .categories a").text
      puts "#{clCenter.name} #{clCenter.int_url} #{clCenter.ext_url} #{clCenter.main_category}"
    end
  end

  def scrape_center_details(center)
    raise InvalidPage, "Invalid page!!!" unless center.is_a? AutoServiceCLI::ServiceCenter || center.int_url.nil?
    puts center.int_url
    doc = Nokogiri::HTML(open(center.int_url))
    raise InvalidPage "Invalid page!!!" if doc == nil

    details = {}

    address_full = []
    address_full << doc.css(".business-card-wrapper .address p.street-address").text
    address_full << doc.css(".business-card-wrapper .address .city-state span").collect {|el| el.text}
    details[:address] = address_full.join(", ") unless address_full.empty?

    open_status = doc.css(".business-card-wrapper .status-text").text
    details[:open_status] = open_status unless open_status.empty?
    tel_number = doc.css(".business-card-wrapper .phone").text
    details[:tel_number] = tel_number unless tel_number.empty?
    rate = doc.css(".business-card-wrapper .result-rating")
    details[:rating] = rate.attr("class").value.split(" ").last unless rate.empty?

    center.details_from_hash(details)
  end

  def scrape_each_center_details
    AutoServiceCLI::ServiceCenter.all.each do |center|
      scrape_center_details(center) unless center.int_url.nil?
    end
  end
end
