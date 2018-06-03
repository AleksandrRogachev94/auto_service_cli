class AutoServiceCLI::Scraper
  attr_reader :zip, :sort_type
  attr_writer :zip, :sort_type

  SORT_TYPES = {
    DEFAULT: "default",
    DISTANCE: "distance",
    AVERAGE_RATING: "average_rating",
    NAME: "name"
  }

  DEFAULT_SORT_TYPE = SORT_TYPES[:default]

  # Constructors and class methods.

  def initialize(zip = nil, sort_type = nil)
    self.zip = zip if zip
    self.sort_type = sort_type ? sort_type : self.class::SORT_TYPES[:DEFAULT]
  end

  def zip=(zip)
    raise InvalidURLData unless self.class.valid_zip?(zip)
    @zip = zip
  end
  def self.valid_zip?(zip)
    zip.to_i > 0
  end

  def sort_type=(type)
    raise InvalidURLData unless self.class.valid_sort_type?(type)
    @sort_type = type
  end
  def self.valid_sort_type?(type)
    SORT_TYPES.any? { |key, value| value == type }
  end

  # def valid_url_data?
  #   self.class.valid_zip?(self.zip) && self.class.valid_sort_type?(self.sort_type)
  # end

  #------------------------------------------------------------------------------------------------
  # Scrape from the main page.
  # Index action.

  def scrape_centers
    doc = Nokogiri::HTML(open(get_url))
    raise InvalidPage "Invalid page!!!" if doc.nil?
    centers = doc.css(".organic .result .info")

    # form centers hash.
    centers.each do |center|

      main_details = {}
      obj_center = AutoServiceCLI::ServiceCenter.create(scrape_name(center))

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
  # Show action.

  def scrape_center_details(center)
    raise InvalidPage, "Invalid page!!!" if !center.is_a? AutoServiceCLI::ServiceCenter || center.int_url.nil?
    doc = Nokogiri::HTML(open(center.int_url))
    raise InvalidPage "Invalid page!!!" if doc.nil?

    details = {}

    status = scrape_status(doc); details[:open_status] = status unless status.nil?
    slogan = scrape_slogan(doc); details[:slogan] = slogan unless slogan.nil?
    hours = scrape_hours(doc); details[:working_hours] = hours unless hours.nil?
    description = scrape_description(doc); details[:description] = description unless description.nil?
    services = scrape_services(doc); details[:services] = services unless services.nil?
    brands = scrape_brands(doc); details[:brands] = brands unless brands.nil?
    payment = scrape_payment(doc); details[:payment] = payment unless payment.nil?

    center.details_from_hash(details)
  end

  #---------------------------------------------------------------------------------------
  # Scraping helpers

  private

  def get_url
    raise InvalidURLData if !self.zip || !self.sort_type
    AutoServiceCLI::URL_TEMPLATE + "#{self.zip}&s=#{self.sort_type}"
  end

  def external_link?(url)
    url.include?("www.") || url.include?("http://") || url.include?("https://")
  end

  def scrape_name(center)
    center.css(".n a").text
  end

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
      attributes = rate.attr("class").value.split(" ");
      attributes.slice(1, attributes.size - 1)
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

  def scrape_status(doc)
    open_status = doc.css(".business-card-wrapper .status-text")
    open_status.empty? ? nil : open_status.text
  end

  def scrape_slogan(doc)
    slogan = doc.css("#business-info .slogan")
    puts slogan
    slogan.empty? ? nil : slogan.text
  end

  def scrape_hours(doc)
    working_hours = ""
    doc.css("#business-info .open-hours time").each do |time|
      working_hours << time.css(".day-label").text
      working_hours << ", " + time.css(".day-hours").text + "\n"
    end
    working_hours.empty? ? nil : working_hours
  end


  def scrape_description(doc)
    description = doc.css("#business-info .general-info p").last
    # description = doc.css("#business-info dd.description").last if description.nil?
    (!description.nil? && description.css("a").empty?) ? description.text : nil #exclude case of facebook and twitter links, without decription
  end

  def scrape_services(doc)
    for_services = doc.css("#business-info dl")[1]
    unless for_services.nil?
      if for_services.css("dt").first.text == "Services/Products:"
        services = for_services.css("dd").first.text
        return services.empty? ? nil : services
      end
    end
    nil
  end

  def scrape_brands(doc)
    brands = doc.css("#business-info .brands")
    brands.empty? ? nil : brands.text
  end

  def scrape_payment(doc)
    payment = doc.css("#business-info .payment")
    payment.empty? ? nil : payment.text
  end

end
