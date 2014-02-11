class Slice
  attr_accessor :legs
  attr_accessor :travelDuration
  attr_accessor :marketingAirline
  
  def initialize
    @legs = Array.new
  end
  
  def travelDuration
    return Duration.new(@travelDuration).format("%thhrs:%mmin")
  end
  
end