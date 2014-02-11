class User
  attr_accessor :id
  attr_accessor :name 
  attr_accessor :hometown
  attr_accessor :location
  attr_accessor :picture
  attr_accessor :link
  attr_accessor :latitude
  attr_accessor :longitude
  attr_accessor :bestAirport
  attr_accessor :guessAirport
  
  def initialize(id, name, hometown, location, picture, link)
    @id = id
    @name = name
    @hometown = hometown
    @location = location
    @picture = picture
    @link = link
    if !@location.nil?
      @guessAirport = false
      @bestAirport = resolveBestAirport
    end
  end
  
  def resolveBestAirport
    bestResolved = AirportCodeFinder.new.lookup(@location)
    if !bestResolved.nil?
      return bestResolved
    else 
      @guessAirport = true     
      return AirportCodeFinder.new.bestGuessByState(@location['name'].split(',')[-1].strip)
    end
  end
  
end