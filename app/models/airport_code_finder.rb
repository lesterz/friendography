class AirportCodeFinder
  @@codes = {"Dubai"=>"DXB", "Kochi"=>"COK", "Bangalore"=>"BLR", "New Delhi"=>"DEL", "Mumbai"=>"BOM", "Washington" => "WAS", "Istanbul" => "IST", "Athens" => "ATH", "Rome" => "ROM", "Brooklyn" => "NYC", "Singapore" => "SIN", "Los Angeles" => "LAX", "San Francisco" => "SFO", "Las Vegas" => "LAS", "Berlin" => "BER", "Chicago" => "CHI", "London" => "LON", "Atlanta" => "ATL", "Boston" => "BOS", "Seattle" => "SEA", "Helsinki" => "HEL", "Paris" => "CDG", "Warsaw" => "WAW", "Miami" => "MIA", "New York" => "NYC", "Aguadilla" => "SJU"}    
  @@city_state_codes = {"Portland, Oregon"=>"PDX", "Portland, Maine"=>"PWM", "Portland, Texas"=>"SAT", "Portland, Victoria"=>"MEL", "Tyler, Texas"=>"DFW", "Weslaco, Texas"=>"MFE"}
  @@best_state_airport_guess = {"Sinaloa"=>"MZT", "Hungary"=>"BUD", "Italy"=>"ROM", "Austria"=>"VIE", "Brussels"=>"BRU", "Michigan"=>"DTW", "Ohio"=>"CLE", "Texas"=>"DFW", "Pennsylvania"=>"PHL", "Virginia"=>"RIC", "Illinois"=>"CHI", "Indiana"=>"IND", "Florida"=>"MIA", "Maryland"=>"BWI", "Massachusetts" => "BOS", "New York" => "NYC", "California" => "LAX", "Oregon"=>"PDX", "Washington"=>"SEA", "United Kingdom" => "LON", "Switzerland" => "ZRH", "France" => "PAR", "Czech Republic" => "PRG"}
  @@reverse_codes = {"NYC" => ["New York", "Brooklyn", "Queens", "Manhattan"], "CHI" => ["Chicago", "Naperville"]}
  
  def initialize
    
  end
  
  def lookup(location)
    if @@codes[location['name'].split(',')[0]]
      return @@codes[location['name'].split(',')[0]]
    else
      return @@city_state_codes[location['name']]
    end
  end
  
  def bestGuessByState(location)
    return @@best_state_airport_guess.fetch(location, "None")
  end
  
  def reverseCodeByName(location)
    # iterate over Array Keys to find the code.  Watch performance here...
  end 
end