class AutoServiceCLI::CLI

  def call

    s = AutoServiceCLI::Scraper.new(17402)
    s.scrape_centers
    3.times do
      s.scrape_center_details(AutoServiceCLI::ServiceCenter.all[11])
      puts AutoServiceCLI::ServiceCenter.all[11].inspect
      puts "--------------------------------------------------------------------------------------"
      puts AutoServiceCLI::ServiceCenter.all[11].working_hours
    end

  end

end
