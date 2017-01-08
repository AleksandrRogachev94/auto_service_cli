class AutoServiceCLI::CLI

  attr_reader :zip, :cur_sort_type
  attr_reader :scraper

  def initialize
    self.cur_sort_type = "default"
  end

  def call
    puts "\n\tWelcome to auto service centers searching CLI!".green
    prompt_zip
    scrape_main_page
    list_centers
    menu
  end

  def prompt_zip
    begin
      puts "\tEnter you zip code:".magenta
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

  #-----------------------------------------------------------------------------------
  # Menu methods

  def menu
    loop do
      help_menu
      puts "\nMake a choise:".magenta
      input = gets.strip
      case input
      when "1"
        list_centers
      when "2"
        sort
      when "3"
        get_details
      when "4"
        scrape_main_page
        list_centers
      when "10"
        goodbye
        break
      end
    end
  end

  def list_centers
    puts "-----------------------------------------------------------------------------"
    puts "\tZIP: #{self.scraper.zip}\n\tSorting type: #{self.scraper.sort_type}\n".cyan
    AutoServiceCLI::ServiceCenter.all.each.with_index(1) do |center,i|
      print "#{i}.".cyan; print " #{center.name}"
      puts center.rating.nil? ? "" : ", rating: #{center.rating}"
    end
    puts "-----------------------------------------------------------------------------"
  end

  def sort
    help_sort
    puts "\n\tChoose type of sorting:".magenta
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
    puts "\n\tEnter the number of center:".green
    input = gets.strip

    if input.to_i >= 1 && input.to_i <= AutoServiceCLI::ServiceCenter.all.size
      center = AutoServiceCLI::ServiceCenter.all[input.to_i - 1]
      unless center.int_url.nil?
        puts "\nObtaining data..."
        self.scraper.scrape_center_details(center)
        puts "Done"
      end

      puts "----------------------------------------------------------------------------------------------------------------"
      puts "\n\t#{center.name.upcase}\n".red
      puts "\tRating:\n#{center.rating}\n".cyan unless center.rating.nil?
      puts "\tCategory:\n#{center.main_category}\n".cyan unless center.main_category.nil?
      puts "\tAddress:\n#{center.address}\n".cyan unless center.address.nil?
      puts"\tPhone number:\n#{center.phone_number}\n".cyan unless center.phone_number.nil?

      unless center.int_url.nil?
        puts "\tStatus:\n#{center.open_status}\n".cyan unless center.open_status.nil?
        puts "\tSlogan:\n#{center.slogan}\n".cyan unless center.slogan.nil?
        puts "\tWorking hours:\n#{center.working_hours}".cyan unless center.working_hours.nil?
        puts "\tDescription:\n#{center.description}\n".cyan unless center.description.nil?
        puts "\tServices:\n#{center.services}\n".cyan unless center.services.nil?
        puts "\tBrands:\n#{center.brands}\n".cyan unless center.brands.nil?
        puts "\tPayment methods:\n#{center.payment}\n".cyan unless center.payment.nil?
      end

      puts "\tSee more at:\n#{center.ext_url}\n".cyan unless center.ext_url.nil?
      puts "----------------------------------------------------------------------------------------------------------------"
    end
  end

  def scrape_main_page
    puts "Obtaining data..."
    AutoServiceCLI::ServiceCenter.reset_all!
    case self.cur_sort_type
    when "default"
      @scraper = AutoServiceCLI::Scraper.new(self.zip, self.cur_sort_type)
    when "distance"
      @scraper =  AutoServiceCLI::Scraper.new(self.zip, self.cur_sort_type)
    when "average_rating"
      @scraper =  AutoServiceCLI::Scraper.new(self.zip, self.cur_sort_type)
    when "name"
      @scraper =  AutoServiceCLI::Scraper.new(self.zip, self.cur_sort_type)
      puts "name"
    end
    self.scraper.scrape_centers
    puts "Done"
  end

  #-----------------------------------------------------------------------------------
  # Helper methods

  def help_menu
    puts "\n1. List centers".green
    puts "2. Change sorting type".green
    puts "3. Show details about service center".green
    puts "4. Reload centers".green
    puts "10. Exit".green
  end

  def help_sort
    puts "\n\t1. Default".green
    puts "\t2. Sort by distance".green
    puts "\t3. Sort by rating".green
    puts "\t4. Sort by name".green
  end

  def goodbye
    puts "\n\tThank you for using this application!".blue
  end
end
