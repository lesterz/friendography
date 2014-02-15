module SearchHelper
  
  class ParamsBundle    
    def initialize
      @params = {}
    end
    
    def params(params)
      @params[:pointOfSale] = 'ORB'
      @params[:origin] = params[:from]
      @params[:destination] = params[:where_to]
      if params[:adults].blank?
        @params[:adults] = 1
      else
        @params[:adults] = params[:adults]
      end
      @params[:seniors] = 0
      if params[:departDate].blank?
        departDay = DateTime.now.next_month + 1.month
      else
        departDay = params[:departDate]
      end
      
      if params[:returnDate].blank?
        returnDay = departDay + 1.week
      else
        returnDay = params[:returnDate]
      end
      @params[:departDate] = departDay.strftime("%Y-%m-%d")
      @params[:returnDate] = returnDay.strftime("%Y-%m-%d")
      @params[:cabinClass] = 'C'
      @params[:preferNonStop] = 'false'
      @params[:refundableOnly] = 'false'
      @params[:suggestDisambiguation] = 'false'
      
      return @params
    end
  end
  
  class FlightSearch
    def initialize        
    end
    
    def search_flights(xmlRequest)      
      # Make net connection and send/recieve request    
      uri = URI.parse(TRAVEL_API_URI)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      request = Net::HTTP::Post.new(uri.request_uri)
      request.content_type = "application/xml"
      request.basic_auth USERNAME, PASSWORD
      request.content_type = 'UTF-8'
      request.content_length = xmlRequest.to_xml.length
      request.body = xmlRequest.to_xml
      Rails.logger.info("Requesting flights now " + Time.now.to_s)
      response = http.request(request) # Live Request, be careful with these
      # reader = Nokogiri::XML::Reader(File.open("app/lib/data/test_flight_response.xml")) # Mock Reader Response
      # fileN = File.new("app/lib/data/test_flight_response_BER-LON.xml", "w")  # Write response to mock file
      # fileN.puts(response.body)
      parser = Nokogiri::XML::SAX::Parser.new(FlightResponseDoc.new)
      # parser.parse(File.open("app/lib/data/test_flight_response_BER-SEA.small.xml")) # parse mock response with SAX
      Rails.logger.info("Returned, parsing now " + Time.now.to_s)
      parser.parse(response.body) # parse live response
      # reader = Nokogiri::XML::Reader(response.body)
      # Rails.logger.info(response.inspect)
      # Rails.logger.info(response.body) 
      return parser.document.solutions
    end 
  end
  
  class Dates
    def initialize      
    end
    
    def validate(potDepart, potReturn)
      dep = validateSingleDate(potDepart)
      ret = validateSingleDate(potReturn)

      if !dep && !ret
        Rails.logger.info("dates are either nil or in the past")
        return false
      end
      if (dep && ret)
        if (potReturn < potDepart)
          Rails.logger.info("Dates were reverse")
          return false
        end
      end
      
      return true
    end
    
    def validateSingleDate(date)
      if date.nil?
        return false
      end
      if date.past?
        Rails.logger.info("Date in the past: " + date.to_s)
        return false
      end 
      return true
    end
    
  end
end
