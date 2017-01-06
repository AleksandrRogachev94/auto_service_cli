class AutoServiceCLI::ServiceCenter
  attr_accessor :name, :url
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

  # Class mehods

  def self.reset_all!
    @@all.clear
  end

  def self.all
    @@all.dup.freeze
  end
end
