class WelcomeController < ApplicationController
  def splash
    @pagename = "splash"
    @email = params[:user][:address] if params[:user]
    if @email
      #send email address to friendography
      ses = AWS::SimpleEmailService.new
      ses.send_email(:subject => 'New email via friendography.com',
                     :from => 'friendography@gmail.com',
                     :to => 'friendography@gmail.com',
                     :body_text => @email.to_s)
      @name  = @email.split('@')[0]
    end
  end
end
