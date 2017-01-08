# Specifications for the CLI Assessment

Specs:
- [x] Have a CLI for interfacing with the application\n
The CLI class was implemented to show users the interface. It has a #call method which is a starting point of CLI. A user should enter a zip code to get info about service centers near him. CLI class has menu method which gives a user an opportunity to make choices: list centers, choose sorting type, show details about center, reload centers, and exit.

- [x] Pull data from an external source\n
yellowpages.com is used to scrape the data about 30 service centers near entered zip code. Gem 'nokogiri' is used to scrape the data. The main page about service centers is used to scrape main data. When a user chooses to see the data about specific center, program scrapes data from additional url (if available) obtained from the main page.

- [x] Implement both list and detail views\n
In CLI class #list_centers method was implemented. It shows 30 centers near entered zip code.
In CLI class #get_details method was implemented. It invokes method to scrape the data from the specific url and list the results.
