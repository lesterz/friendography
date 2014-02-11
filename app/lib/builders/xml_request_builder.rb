class XmlRequestBuilder

  def build(params = {})    
    pointOfSale = params.fetch(:pointOfSale)
    origin = params.fetch(:origin)
    destination = params.fetch(:destination)
    adults = params.fetch(:adults)
    seniors = params.fetch(:seniors)
    preferNonStop = params.fetch(:preferNonStop)
    refundableOnly = params.fetch(:refundableOnly)
    suggestDisambiguation = params.fetch(:suggestDisambiguation)
    cabinClass = params.fetch(:cabinClass)
    departDate = params.fetch(:departDate)
    returnDate = params.fetch(:returnDate)
    
    # orig = AirportCodeFinder.new.lookup(origin)
    # dest = AirportCodeFinder.new.lookup(destination)
    builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
      xml.send(:AirShoppingRequest, :xmlns => "http://ws.orbitz.com/schemas/2008/Air") {
        xml.PointOfSale pointOfSale
        xml.AirSearchType("code" => "BASIC")
        xml.Travelers {
          xml.Adults adults
        }
        xml.Slices("preferNonStop" => preferNonStop, "refundableOnly" => refundableOnly, "suggestDisambiguation" => suggestDisambiguation) {
          xml.CabinType("code" => cabinClass)
          xml.Slice {
            xml.Departure {
              xml.Airport("code" => origin)
              xml.Date departDate
            }
            xml.Arrival {
              xml.Airport("code" => destination)
            }
          }
          xml.Slice {
            xml.Departure {
              xml.Airport("code" => destination)
              xml.Date returnDate
            }
            xml.Arrival {
              xml.Airport("code" => origin)
            }
          }
        }
        xml.DistributionPartnerDetails       
      }
    end
  end
  
end