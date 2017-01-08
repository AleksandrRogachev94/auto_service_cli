require "open-uri"
require "nokogiri"
require "colorize"
require "pry"

require_relative "auto_service_cli/constants"
require_relative "auto_service_cli/service_center"
require_relative "auto_service_cli/scraper"
require_relative "auto_service_cli/cli"

# Modules

module AutoServiceCLI
end

# Errors

class InvalidURLData < StandardError; end
class InvalidPage < StandardError; end
