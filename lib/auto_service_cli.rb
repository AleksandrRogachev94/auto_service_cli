require "open-uri"
require "nokogiri"
require "pry"

require_relative "auto_service_cli/version"
require_relative "auto_service_cli/constants"
require_relative "auto_service_cli/service_center"
require_relative "auto_service_cli/scraper"

# Modules

module AutoServiceCLI
end

# Errors

class InvalidURLData < StandardError; end
class InvalidURL < StandardError; end
