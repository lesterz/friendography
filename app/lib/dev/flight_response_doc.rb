class FlightResponseDoc < Nokogiri::XML::SAX::Document
  attr_accessor :solutions
  
  def initialize
    @solutions = Array.new
  end
  
  def start_element name, attrs = []
    if (name == 'Solution')
      @solution = Solution.new
    end
    if (name == 'Rate')
      @solution.deepLink = Hash[attrs]['href']
    end
    if (name == 'Adults')
      @solution.adults = Hash[attrs]['count']
    end
    if (name == 'TotalCost') 
      @solution.totalCostCurrency = Hash[attrs]['currency']     
      @is_totalCost = true
    end
    if (name == 'Slices')
      @is_slices = true
    end
    if (name == 'Slice')
      @slice = Slice.new
      @slice.travelDuration = Hash[attrs]['travelDuration']      
      @is_slice = true
    end
    if (name == 'MarketingAirline' && @is_slice)
      @is_slice_marketing_airline = true
    end
    if (name == 'Leg')
      @leg = Leg.new
      @is_leg = true
    end
    if (name == 'FlightNumber')
      @is_flightNumber = true
    end
    if (name == 'EquipmentType')
      @is_equipmentType = true
    end
    if (name == 'Departure')
      @departure = Departure.new
      @is_departure = true
    end
    if (name == 'Airport' && @is_departure)
      @dep_airport = Airport.new
      @is_dep_airport = true
    end
    if (name == 'com:Id' && @is_departure)
      @is_dep_comId = true
    end
    if (name == 'com:Name' && @is_departure)
      @is_dep_comName = true
    end
    if (name =='com:CityName' && @is_departure)
      @is_dep_comCityName = true
    end
    if (name == 'Time' && @is_departure)
      @is_dep_time = true
    end
    if (name == 'Arrival')
      @arrival = Arrival.new
      @is_arrival = true
    end
    if (name == 'Airport' && @is_arrival)
      @arr_airport = Airport.new
      @is_arr_airport = true
    end
    if (name == 'com:Id' && @is_arrival)
      @is_arr_comId = true
    end
    if (name == 'com:Name' && @is_arrival)
      @is_arr_comName = true
    end
    if (name =='com:CityName' && @is_arrival)
      @is_arr_comCityName = true
    end
    if (name == 'Time' && @is_arrival)
      @is_arr_time = true
    end
    if (name == 'AirFareInfos')    
      @is_airFareInfos = true
    end
    if (name == 'AirFareInfo')
      @airFareInfo = AirfareInfo.new      
      @is_airFareInfo = true
    end
    if (name == 'Carrier')
      @is_carrier = true
    end
    if (name == 'DepartureCode' && @is_airFareInfo)
      @is_departureCode = true
    end
    if (name == 'ArrivalCode' && @is_airFareInfo)
      @is_arrivalCode = true
    end
  end
  
  def characters data  
    if @is_totalCost  
      @solution.totalCost = data
      @is_totalCost = false
    end
    if @is_slice_marketing_airline
      @solution.marketingAirlines.push(data)
      @is_slice_marketing_airline = false
    end
    if @is_flightNumber
      @leg.flightNumber = data
      @is_flightNumber = false
    end
    if @is_equipmentType
      @leg.planeType = data
      @is_equipmentType = false
    end
    if @is_dep_comId
      @dep_airport.id = data
      @is_dep_comId = false
    end
    if @is_dep_comName
      @dep_airport.name = data
      @is_dep_comName = false
    end
    if @is_dep_comCityName
      @dep_airport.cityName = data
      @is_dep_comCityName = false
    end
    if @is_dep_time
      @departure.time = data
      @is_dep_time = false
    end
    if @is_arr_comId
      @arr_airport.id = data
      @is_arr_comId = false
    end
    if @is_arr_comName
      @arr_airport.name = data
      @is_arr_comName = false
    end
    if @is_arr_comCityName
      @arr_airport.cityName = data
      @is_arr_comCityName = false
    end
    if @is_arr_time
      @arrival.time = data
      @is_arr_time = false
    end
    if @is_carrier
      @airFareInfo.carrier = data
      @is_carrier = false
    end
    if @is_departureCode
      @airFareInfo.departureCode = data
      @is_departureCode = false
    end
    if @is_arrivalCode
      @airFareInfo.arrivalCode = data
      @is_arrivalCode = false
    end
  end

  def end_element name
    if (name == 'EquipmentType')
    end
    if (name == 'FlightNumber')      
    end
    if (name == 'Leg')
      @slice.legs.push(@leg)
      @is_leg = false
    end
    if (name == 'Solution')
      @solutions.push(@solution)
    end
    if (name == 'Rate')
    end
    if (name == 'Adults')      
    end
    if (name == 'TotalCost') 
    end
    if (name == 'Slice')
      @solution.slices.push(@slice)
      @is_slice = false
    end
    if (name == 'Slices')
      @is_slices = false
    end
    if (name == 'Departure')
      @leg.departure = @departure
      @is_departure = false
    end
    if (name == 'Arrival')
      @leg.arrival = @arrival
      @is_arrival = false
    end
    if (name == 'Airport' && @is_departure)
      @departure.airport = @dep_airport
      @is_dep_airport = false
    end
    if (name == 'Airport' && @is_arrival)
      @arrival.airport = @arr_airport
      @is_arr_airport = false
    end
    if (name == 'AirFareInfo')
      @solution.airfareInfos.push(@airFareInfo)
      @is_airFareInfo = false
    end
    if (name == 'AirFareInfos')
      @is_airFareInfos = false
    end
  end
end
