class Departure
  attr_accessor :airport
  attr_accessor :time
  
  def time
    return @time.to_time.strftime("%m/%d")
  end
end