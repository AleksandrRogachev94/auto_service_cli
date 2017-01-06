class AutoServiceCLI::ServiceCenter
  attr_accessor :name,
                :int_url,
                :ext_url,
                :main_category,
                :open_status,
                :address,
                :tel_number,
                :rating
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
    details.each do |detail, value|
      self.send("#{detail}=", value)
    end
    format_rating unless self.rating.nil?
  end

  def format_rating
    case self.rating
    when "one"
      self.rating = "1 star"
    when "two"
      self.rating = "2 stars"
    when "three"
      self.rating = "3 stars"
    when "four"
      self.rating = "4 stars"
    when "five"
      self.rating = "5 stars" 
    end
  end

  # Class mehods

  def self.reset_all!
    @@all.clear
  end

  def self.all
    @@all.dup.freeze
  end
end
