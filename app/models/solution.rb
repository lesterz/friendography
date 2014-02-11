class Solution
  attr_accessor :totalCost
  attr_accessor :totalCostCurrency
  attr_accessor :deepLink
  attr_accessor :marketingAirlines
  attr_accessor :slices
  attr_accessor :airfareInfos
  attr_accessor :departDate
  attr_accessor :returnDate
  attr_accessor :adults
  
  def initialize
    @slices = Array.new
    @marketingAirlines = Array.new
    @airfareInfos = Array.new
  end  
  
  def deepLink
    # Better to find a way of getting escaped & in url instead of stripping it here...
    return @deepLink.gsub(/#38;/, '').gsub(/&dp=ntest&WT.mc_ev=click/, '').gsub(/&WT.mc_id=EBDE_AIR_ntest/, '').gsub(/&WT.mc_id=EBUK_AIR_ntest/, '').gsub(/&WT.mc_id=ORB_AIR_ntest/, '')
  end
  
  def totalCost
    case @totalCostCurrency
    when "GBP"
      return ActionController::Base.helpers.number_to_currency(@totalCost, :unit => '&pound;', :format => "%n %u")
    when "EUR"
      return ActionController::Base.helpers.number_to_currency(@totalCost, :unit => '&euro;', :format => "%n %u")
    else
      return ActionController::Base.helpers.number_to_currency(@totalCost)
    end
  end
    
end