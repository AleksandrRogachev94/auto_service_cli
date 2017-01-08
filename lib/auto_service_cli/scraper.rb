class AutoServiceCLI::Scraper
  attr_reader :doc, :sort_type, :zip

  # Constructors and class methods.

  def initialize(zip, sort_type = "default")
    @sort_type = sort_type
    @zip = zip
    @doc = Nokogiri::HTML(open(get_url))
  end

  def self.valid_zip?(zip)
      zip.to_i > 0
  end

  def self.valid_sort_type?(type)
    type == "default" || type == "distance" || type == "average_rating" || type == "name"
  end

  # Helper methods

  def get_url
    raise InvalidURLData, "Invalid input data: zip - #{self.zip}, sort type - #{self.sort_type}" unless valid_url_data?
    AutoServiceCLI::URL_TEMPLATE + "#{self.zip}&s=#{self.sort_type}"
  end

  def valid_url_data?
    self.class.valid_zip?(self.zip) && self.class.valid_sort_type?(self.sort_type)
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
      obj_center = AutoServiceCLI::ServiceCenter.create(center.css(".n a").text)

      url = scrape_internal_url(center); main_details[:int_url] = url unless url.nil?
      url = scrape_external_url(center); main_details[:ext_url] = url unless url.nil?
      rating = scrape_rating(center); main_details[:rating] = rating unless rating.nil?
      address = scrape_address(center); main_details[:address] = address unless address.nil?
      phone = scrape_phone_number(center); main_details[:phone_number] = phone unless phone.nil?
      category = scrape_category(center); main_details[:main_category] = category unless category.nil?

      obj_center.details_from_hash(main_details) # setting all details to center.
    end
  end

  #------------------------------------------------------------------------------------------------
  # Scrape center details from the internal url (if available)

  def scrape_center_details(center)
    raise InvalidPage, "Invalid page!!!" if !center.is_a? AutoServiceCLI::ServiceCenter || center.int_url.nil?
    doc = Nokogiri::HTML(open(center.int_url))
    raise InvalidPage "Invalid page!!!" if doc == nil

    details = {}

    status = scrape_status(doc); main_details[:open_status] = status unless status.nil?
    slogan = scrape_slogan(doc); main_details[:slogan] = slogan unless slogan.nil?
    hours = scrape_hours(doc); main_details[:workin_hours] = hours unless hours.nil?

    slogan = doc.css("#business-details .slogan").text
    details[:slogan] = slogan unless slogan.empty?

    working_hours = ""
    doc.css("#business-details .open-hours time").each do |time|
      working_hours << time.css(".day-label").text
      working_hours << ", " + time.css(".day-hours").text + "\n"
    end
    details[:working_hours] = working_hours unless working_hours.empty?

    description = doc.css("#business-details p.description").last
    description = doc.css("#business-details dd.description").last if description.nil?
    details[:description] = description.text if !description.nil? && description.css("a").empty? #exclude case of facebook and twitter links, without decription

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

  def scrape_status(doc)
    open_status = doc.css(".business-card-wrapper .status-text")
    open_status.empty? ? nil : open_status.text
  end

  #---------------------------------------------------------------------------------------
  # Scraping helpers

private

  def scrape_internal_url(center)
    url = center.css(".n a").attr("href").value
    (!url.empty? && !external_link?(url)) ? AutoServiceCLI::URL_BASE + url : nil
  end

  def scrape_external_url(center)
    url = center.css(".links a.track-visit-website")
    url.empty? ? nil : url.attr("href").value
  end

  def scrape_rating(center)
    rate = center.css(".info-primary .result-rating")
    unless rate.empty?
      attributes = rate.attr("class").value.split(" "); attributes.slice(1, attributes.size-1)
    else
      nil
    end
  end

  def scrape_address(center)
    address_full = center.css(".info-primary .adr span").collect {|el| el.text.split(",").first}
    address_full.flatten.empty? ? nil : address_full.join(", ")
  end

  def scrape_phone_number(center)
    phone_number = center.css(".info-primary .phone.primary")
    phone_number.empty? ? nil : phone_number.text
  end

  def scrape_category(center)
    category = center.css(".info-secondary .categories a")
    category.empty? ? nil : category.text
  end
end
