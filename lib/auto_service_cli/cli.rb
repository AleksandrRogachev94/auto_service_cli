class AutoServiceCLI::CLI

  attr_reader :zip, :cur_sort_type
  attr_reader :scr_sort_default, :scr_sort_distance, :scr_sort_rating, :scr_sort_name

  def initialize
    self.cur_sort_type = "default"
  end

  def call
    puts "Welcome to auto service centers searching CLI!"
    prompt_zip

    puts "Obtaining data..."
    scrape_main_page
    puts "Done"
    list_centers
  end

  # Writers

  def zip=(zip)
    @zip = zip if AutoServiceCLI::Scraper.valid_zip?(zip)
  end

  def cur_sort_type=(type)
    @cur_sort_type = type if AutoServiceCLI::Scraper.valid_sort_type?(type)
  end

  # Helper methods

  def prompt_zip
    begin
      puts "Enter you zip code:"
      zip = gets.strip
    end until AutoServiceCLI::Scraper.valid_zip?(zip)
    self.zip = zip
  end

  def scrape_main_page
    scraper = get_cur_scraper
    scraper = AutoServiceCLI::Scraper.new(self.zip, self.cur_sort_type)
    scraper.scrape_centers
  end

  def get_cur_scraper
    case self.cur_sort_type
    when "default"
      self.scr_sort_default
    when "distance"
      self.scr_sort_distance
    when "rating"
      self.scr_sort_rating
    when "name"
      self.scr_sort_name
    end
  end

  def list_centers
    scr
  end

end
