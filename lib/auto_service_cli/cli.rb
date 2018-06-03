# TODO cur_sort_type string => data type


class AutoServiceCLI::CLI
  attr_accessor :scraper, :scraper
  private :scraper, :scraper=

  def initialize
    self.scraper = AutoServiceCLI::Scraper.new
  end

  def call
    welcome
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
    scraper.zip = zip
  end

  #-----------------------------------------------------------------------------------
  # Menu methods

  def menu
    loop do
      help_menu
      puts "\nMake a choice:".magenta
      input = gets.strip
      case input
      when "1"
        list_centers
      when "2"
        get_details
      when "3"
        sort
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
    puts "\tZIP: #{scraper.zip}\n\tSorting type: #{scraper.sort_type}\n".cyan
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
      scraper.sort_type = AutoServiceCLI::Scraper::SORT_TYPES[:DAFAULT]
    when "2"
      scraper.sort_type = AutoServiceCLI::Scraper::SORT_TYPES[:DISTANCE]
    when "3"
      scraper.sort_type = AutoServiceCLI::Scraper::SORT_TYPES[:AVERAGE_RATING]
    when "4"
      scraper.sort_type = AutoServiceCLI::Scraper::SORT_TYPES[:NAME]
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
        scraper.scrape_center_details(center)
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
    puts "Obtaining data for you... It will take a few seconds"

    # clean up all records.
    AutoServiceCLI::ServiceCenter.reset_all!

    scraper.scrape_centers
    puts "Done"
  end

  #-----------------------------------------------------------------------------------
  # Helper methods

  def welcome
    puts "\n\tWelcome to auto service centers searching CLI!\n\tby Aleksandr Rogachev © #{Time.new.year}\n".green
  end

  def help_menu
    puts "\n1. List centers".green
    puts "2. Show details about service center".green
    puts "3. Change sorting type".green
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
