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

  def external_link?(url)
    url.include?("www.") || url.include?("http://") || url.include?("https://")
  end

  #------------------------------------------------------------------------------------------------
  #Scrape from the main page.

  def scrape_centers
    raise InvalidPage, "Invalid page!!!" if self.doc == nil
    centers = self.doc.css(".organic .result .info")

    centers.each do |center|

      main_details = {}
      # scraping names
      obj_center = AutoServiceCLI::ServiceCenter.create(center.css(".n a").text)
      url = center.css(".n a").attr("href").value

      # scraping url
      unless url.empty?
        if external_link?(url)
          main_details[:ext_url] = url
        else
          main_details[:int_url] = AutoServiceCLI::URL_BASE + url
        end
      end

      # scraping rating
      rate = center.css(".info-primary .result-rating")
      main_details[:rating] = rate.attr("class").value.split(" ").last unless rate.empty?

      # scraping adress
      address_full = []
      address_full << center.css(".info-primary .adr span").collect.with_index {|el,i| el.text.split(",").first}
      main_details[:address] = address_full.join(", ") unless address_full.empty?

      #scraping phone number
      phone_number = center.css(".info-primary .phone.primary").text
      main_details[:phone_number] = phone_number unless phone_number.empty?

      # scraping category
      category = center.css(".info-secondary .categories a").text
      main_details[:main_category] = category unless category.empty?

      obj_center.details_from_hash(main_details) # setting all details to center.
    end
  end

  #------------------------------------------------------------------------------------------------
  # Scrape center details from the internal url (if available)

  def scrape_center_details(center)
    raise InvalidPage, "Invalid page!!!" unless center.is_a? AutoServiceCLI::ServiceCenter || center.int_url.nil?
    doc = Nokogiri::HTML(open(center.int_url))
    raise InvalidPage "Invalid page!!!" if doc == nil

    details = {}

    open_status = doc.css(".business-card-wrapper .status-text").text
    details[:open_status] = open_status unless open_status.empty?

    slogan = doc.css("#business-details .slogan").text
    details[:slogan] = slogan unless slogan.empty?

    working_hours = ""
    doc.css("#business-details .open-hours time").each do |time|
      working_hours << time.css(".day-label").text
      working_hours << ", " + time.css(".day-hours").text + "\n"
    end
    details[:working_hours] = working_hours unless working_hours.empty?

    description = doc.css("#business-details .description").last
    details[:description] = description.text unless description.nil?

    for_services = doc.css("#business-details dl")[1]
    unless for_services.nil?
      if for_services.css("dt").first.text == "Services/Products:"
        services = for_services.css("dd").first.text
        details[:services] = services unless services.empty?
      end
    end

    brands = doc.css("#business-details .brands").text
    details[:brands] = brands unless brands.empty?
    payment = doc.css("#business-details .payment").text
    details[:payment] = payment unless payment.empty?

    center.details_from_hash(details)
  end

  def scrape_each_center_details
    AutoServiceCLI::ServiceCenter.all.each do |center|
      scrape_center_details(center) unless center.int_url.nil?
    end
  end
end
