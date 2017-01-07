class AutoServiceCLI::CLI

  attr_reader :zip, :cur_sort_type
  attr_reader :scr_sort_default, :scr_sort_distance, :scr_sort_rating, :scr_sort_name

  def initialize
    self.cur_sort_type = "default"
  end

  def call
    puts "Welcome to auto service centers searching CLI!"
    prompt_zip
    scrape_main_page
    list_centers
    menu
  end

  def prompt_zip
    begin
      puts "Enter you zip code:"
      zip = gets.strip
    end until AutoServiceCLI::Scraper.valid_zip?(zip)
    self.zip = zip
  end

  # Writers and Readers

  def zip=(zip)
    @zip = zip if AutoServiceCLI::Scraper.valid_zip?(zip)
  end

  def cur_sort_type=(type)
    @cur_sort_type = type if AutoServiceCLI::Scraper.valid_sort_type?(type)
  end

  def get_cur_scraper
    case self.cur_sort_type
    when "default"
      self.scr_sort_default
    when "distance"
      self.scr_sort_distance
    when "average_rating"
      self.scr_sort_rating
    when "name"
      self.scr_sort_name
    end
  end

  #-----------------------------------------------------------------------------------
  # Menu methods

  def menu
    loop do
      help_menu
      puts "\nMake a choise:"
      input = gets.strip
      case input
      when "1"
        list_centers
      when "2"
        sort
      when "3"
        get_details
      when "10"
        goodbye
        break
      end
    end
  end

  def list_centers
    puts "-----------------------------------------------------------------------------"
    AutoServiceCLI::ServiceCenter.all.each.with_index(1) do |center,i|
      print "#{i}. #{center.name}"
      puts center.rating.nil? ? "" : ", rating: #{center.rating}"
    end
    puts "-----------------------------------------------------------------------------"
  end

  def sort
    help_sort
    puts "\tChoose type of sorting:"
    input = gets.strip
    case input
    when "1"
      self.cur_sort_type = "default"
    when "2"
      self.cur_sort_type = "distance"
    when "3"
      self.cur_sort_type = "average_rating"
    when "4"
      self.cur_sort_type = "name"
    end
    scrape_main_page
    list_centers
  end

  def get_details
    puts "Enter the number of center:"
    input = gets.strip

    if input.to_i >= 1 && input.to_i <= 30
      center = AutoServiceCLI::ServiceCenter.all[input.to_i - 1]
      puts "\nName:\n#{center.name}\n\n"
      puts "Rating:\n#{center.rating}\n\n" unless center.rating.nil?
      puts "Category:\n#{center.main_category}\n\n" unless center.main_category.nil?
      puts "Address:\n#{center.address}\n\n" unless center.address.nil?
      puts"Phone number:\n#{center.phone_number}\n\n" unless center.phone_number.nil?

      unless center.int_url.nil?
        puts "Status:\n#{center.open_status}\n\n" unless center.open_status.nil?
        puts "Slogan:\n#{center.slogan}\n\n" unless center.slogan.nil?
        puts "Working hours:\n#{center.working_hours}\n\n" unless center.working_hours.nil?
        puts "Description:\n#{center.description}\n\n" unless center.description.nil?
        puts "Services:\n#{center.services}\n\n" unless center.services.nil?
        puts "Brands:\n#{center.brands}\n\n" unless center.brands.nil?
        puts "Payment methods:\n#{center.payment}\n\n" unless center.payment.nil?
      end

      puts "See more at:\n#{center.ext_url}\n" unless center.ext_url.nil?
    end
  end

  def scrape_main_page
    puts "Obtaining data..."
    AutoServiceCLI::ServiceCenter.reset_all!
    case self.cur_sort_type
    when "default"
      @scr_sort_default = AutoServiceCLI::Scraper.new(self.zip, self.cur_sort_type)
      puts "default"
    when "distance"
      @scr_sort_distance =  AutoServiceCLI::Scraper.new(self.zip, self.cur_sort_type)
      puts "distance"
    when "average_rating"
      @scr_sort_rating =  AutoServiceCLI::Scraper.new(self.zip, self.cur_sort_type)
      puts "average_rating"
    when "name"
      @scr_sort_name =  AutoServiceCLI::Scraper.new(self.zip, self.cur_sort_type)
      puts "name"
    end
    puts get_cur_scraper.get_url
    get_cur_scraper.scrape_centers
    puts "Done"
  end

  #-----------------------------------------------------------------------------------
  # Helper methods

  def help_menu
    puts "1. list centers"
    puts "2. sort centers"
    puts "3. details about center"
    puts "10. exit"
  end

  def help_sort
    puts "\t1. sort by default"
    puts "\t2. sort by distance"
    puts "\t3. sort by rating"
    puts "\t4. sort by name"
  end

  def goodbye
    puts "Thank you for using this application!"
  end
end
