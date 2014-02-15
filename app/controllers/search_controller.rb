require 'date'

class SearchController < ApplicationController

  def initialize
    @friends = []
  end
  
  def search
    oauth = nil
    begin
      if (session[:departDate].blank? && session[:returnDate].blank?)
        @defaultDepart = DateTime.now.next_month + 1.month
        @defaultReturn = @defaultDepart + 1.week
        @defaultAdults = 1
        session[:departDate] = @defaultDepart
        session[:returnDate] = @defaultReturn
      else
        @defaultDepart = session[:departDate]
        @defaultReturn = session[:returnDate]
        @defaultAdults = session[:adults]       
      end
     
      if (cookies["fbsr_"+FB_APP_ID].nil?)
        logger.info("Current User Not using Facebook")
        cookies["use_fb"] = false
      else        
        if (!session[:access_token].nil?)
          graph = Koala::Facebook::API.new(session[:access_token])
          cookies["use_fb"] = true
        else
          oauth = Koala::Facebook::OAuth.new(FB_APP_ID, FB_APP_SECRET)
          fbCookies ||= oauth.get_user_info_from_cookies(cookies)
          extended_token = oauth.exchange_access_token_info(fbCookies['access_token'])
          graph = Koala::Facebook::API.new(extended_token['access_token'])
          session[:access_token] = extended_token['access_token']
          session[:token_expiry] = DateTime.now + extended_token['expires'].to_i.seconds
          cookies["use_fb"] = true      
        end
        
        @me = graph.get_object("me", :fields => "id,name,link,picture.type(square),location,hometown")
        @currentUser = User.new(@me['id'], @me['name'], @me['hometown'], @me['location'], @me['picture'], @me['link'])
        if @me['location']
          fqlQuery = "SELECT location, name FROM page WHERE page_id = " + @me['location']['id']             
          coordinates = graph.fql_query(fqlQuery).first['location']
          @currentUser.latitude = coordinates['latitude']
          @currentUser.longitude = coordinates['longitude']
        end

        fb_friendList = graph.get_connections("me", "friends?fields=id,name,link,picture.type(square),location,hometown")
        
        fqlQuery = "SELECT location, name FROM page WHERE page_id in (SELECT current_location.id from user WHERE uid IN (SELECT uid2 FROM friend WHERE uid1=me()))"
        fb_locationNodes = graph.fql_query(fqlQuery)        
        fb_friendList.each do |fb_friend|
          friend = Friend.new(fb_friend['id'], fb_friend['name'], fb_friend['link'], fb_friend['hometown'], fb_friend['location'], fb_friend['picture'])      
          if (fb_friend['location'])
            f_location = fb_locationNodes.find { |x| x['name'] == fb_friend['location']['name']}
            friend.latitude = f_location['location']['latitude']
            friend.longitude = f_location['location']['longitude']
          end
          @friends << friend       
        end
    end
    
    # A specific auth exception like accessToken expired or auth denied.
    rescue Koala::Facebook::OAuthTokenRequestError
      logger.info("Caught OAuthException condition from oauth attempt")
      logger.info("Cookies: " + cookies.inspect)
      flash[:notice] = "Error with OAuth"
      redirect_to action: 'handle500'  # Redirect to a "safer" 500 error page.
      
    rescue Koala::Facebook::OAuthSignatureError
      logger.info("Caught OauthSignatureError from get_user_from_cookie...")
      logger.info("Cookies: " + cookies.inspect)
      flash[:notice] = "Error with OAuth Signature Key"
      redirect_to action: 'handle500' # Redirect to a "safer" 500 error page.
      
    # User not logged in OR something technical went wrong during auth OR Facebook blew up during some massive operation!
    rescue nil 
      logger.info("Caught nil condition from oauth attempt")
      flash[:notice] = "Error getting Facebook Data"
      redirect_to :back
    end
    
  end
  
  def logout
    cookies["fbsr_"+FB_APP_ID] = nil
    session[:access_token] = nil
    session[:departDate] = nil
    session[:returnDate] = nil
    session[:adults] = nil
    redirect_to '/search/search'
  end
  
  def search_flights

    if session[:departDate] || session[:returnDate] || session[:adults]
      userParams = Hash.new
      if session[:departDate]
        userParams["departDate"] = session[:departDate]
      end 
      if session[:returnDate]
        userParams["returnDate"] = session[:returnDate]
      end
      if session[:adults]
        userParams["adults"] = session[:adults]
      end
      newParams = params.merge(userParams)
    end
    
    # First Validate to ensure no monkey business from client submit...
    
    # Second Build the Request
    xmlRequest = XmlRequestBuilder.new.build(SearchHelper::ParamsBundle.new.params(newParams)) 
    logger.info(xmlRequest.to_xml)
 
    @solutions = SearchHelper::FlightSearch.new.search_flights(xmlRequest)

    respond_to do | format |
      format.html
      format.js
    end
  end
  
  def set_params
    @defaultDepart = session[:departDate]
    @defaultReturn = session[:returnDate]

    if !params[:depart]['depart'].blank?
      departD = Date.strptime(params[:depart]['depart'], '%m/%d/%Y')
    end
    if !params[:return]['return'].blank?
      returnD = Date.strptime(params[:return]['return'], '%m/%d/%Y')
    end
    if !params[:adults].blank?
      @defaultAdults = params[:adults]
      session[:adults] = @defaultAdults
    end  
      
    if departD || returnD
      if SearchHelper::Dates.new.validate(departD, returnD)
        newDepart = departD || @defaultDepart
        newReturn = returnD || @defaultReturn
        
        if (returnD.nil? || departD.nil?)
          if returnD.nil?
            if departD < @defaultReturn
              session[:departDate] = @defaultDepart = newDepart
              session[:returnDate] = @defaultReturn = newReturn
            end  
          end 
          if departD.nil?
            if @defaultDepart < returnD
              session[:departDate] = @defaultDepart = newDepart
              session[:returnDate] = @defaultReturn = newReturn
            end
          end 
        else
          if departD < returnD
            session[:departDate] = @defaultDepart = newDepart
            session[:returnDate] = @defaultReturn = newReturn
          end          
        end
      else 
        if (session[:departDate].blank? && session[:returnDate].blank?)
          @defaultDepart = DateTime.now.next_month + 1.month
          @defaultReturn = @defaultDepart + 1.week
        else
          @defaultDepart = session[:departDate]
          @defaultReturn = session[:returnDate]   
        end     
      end
    end
    
    respond_to do | format |
      format.html
      format.js
    end       
  end
  
  def feedback
    @email = params[:user][:address] if params[:user]
    @name = params[:user][:name] if params[:user]
    @message = params[:message] if params[:message]
    
    feedback_txt = "FreedBack from " + @name + " email: " + @email + "\n"
    feedback_txt += @message + "\n\n"
    feedback_txt += "Submitted at " + Time.now.to_s + " from " + request.remote_ip
    
    #send email address to friendography
    begin
      ses = AWS::SimpleEmailService.new
      ses.send_email(:subject => 'FeedBack for friendography.com',
                   :from => 'friendography@gmail.com',
                   :to => 'friendography@gmail.com',
                   :body_text => feedback_txt)
     rescue nil
       logger.info("Something went wrong with Amazon Simple Email")       
     end
    
    respond_to do | format |
      format.html
      format.js
    end
  end
  
  def handle500
    logger.info("Handling 500 Internal Server Error")
    respond_to do | format |
      format.html
      format.js
    end    
  end
  
end
