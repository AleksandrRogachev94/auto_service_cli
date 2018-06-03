class AutoServiceCLI::ServiceCenter
  attr_accessor :name,
                :int_url,
                :ext_url,
                :rating,
                :main_category,
                :address,
                :phone_number,
                :open_status,
                :slogan,
                :working_hours,
                :description,
                :services,
                :brands,
                :payment
  @@all = []

  # Constructors

  def initialize(name)
    @name = name
  end

  def self.create(name)
    self.new(name).tap { |center| center.save }
  end

  # Instance methods.

  def save
    @@all << self
  end

  def details_from_hash(details)
    # modify hash's rating
    if details.include?(:rating)
      details[:rating] = format_rating(details[:rating])
    end

    details.each do |detail, value|
      self.send("#{detail}=", value)
    end
  end

  # ex ["two", "half"] or ["two"]
  def format_rating(rating)
    case rating[0]
      when "one"
        new_rating = "1"
      when "two"
        new_rating = "2"
      when "three"
        new_rating = "3"
      when "four"
        new_rating = "4"
      when "five"
        new_rating = "5"
      else
        # assume it's already formatted
        return rating
    end

    # TODO
    new_rating << ".5" if rating.size == 2 && rating.last == "half"
    new_rating + " star(s)"
  end

  # Class mehods

  def self.reset_all!
    @@all.clear
  end

  def self.all
    @@all.dup.freeze
  end
end
