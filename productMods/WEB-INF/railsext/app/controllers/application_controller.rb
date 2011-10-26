class ApplicationController < ActionController::Base

  helper :all # include all helpers, all the time

  alias :logged_in? :user_signed_in?

  
  protect_from_forgery

  def current_user=(user)
    puts "in current_user=(), got user="
    pp user
    puts "NOT signing in user"
  end

  def current_user
    puts "in current_user(), found @current_user="
    pp @current_user
    puts "current_token="
    pp current_token
    return @current_user
  end

  def authenticate_user_vivo
    puts "in custom authn routine for VIVO user"
    puts "Rails params from authz form:"
    pp params
    
    puts "servlet request object:"
    pp servlet_request
    puts "params from servlet request:"
    servlet_request_params = servlet_request.getParameterMap()
    pp (servlet_request_params || "")

    pp session
    pp servlet_request

    puts "Testing each() call on Java Enum instance"
    
    servlet_request.getSession.attribute_names.each {|i| 
      puts "   " + i + " => " 
      pp servlet_request.getSession.getAttribute(i) 
    }

    puts "Full request URL=" + servlet_request.request_uri + (servlet_request.query_string|| "")
    
    # Pull some information out of the Java servlet session
    session = servlet_request.session()    
    loginStatus = session.get_attribute("loginStatus")
    if loginStatus
      puts "Got loginStatus.toString=" + loginStatus.to_string
      
      # Instantiate the user in Rails, may need to create one if it doesn't exist
      #vivo_user = loginStatus.getCurrentUser(session)
      puts "tricky, calling getCurrentUser method with session argument:"
      vivo_user = loginStatus.java_send :getCurrentUser, [java.lang.Class.for_name("javax.servlet.http.HttpSession")], session
      #vivo_user = loginStatus.java_send :getCurrentUser, [org.apache.catalina.session.StandardSessionFacade], session
      #vivo_user = loginStatus.java_send :getCurrentUser, [javax.servlet.http.HttpServletRequest], servlet_request
      #method = loginStatus.java_method :getCurrentUser, [javax.servlet.http.HttpServletRequest]

      puts "Got vivo_user.toString" + vivo_user.to_string
      puts "creating-or-finding Rails user w/ email=" + vivo_user.email_address
      @current_user = User.find_by_email(vivo_user.email_address)
      if !@current_user
        puts "User does not exist in Rails, need to create one with email="+vivo_user.email_address+", uri="+vivo_user.uri
        @current_user = User.new(:email => vivo_user.email_address, :uri => vivo_user.uri)
        @current_user.save!
      end
    else
      puts "User is not logged in, redirecting to VIVO authn form"

      # Show flash message above the login form
      session.setAttribute("edu.cornell.mannlib.vitro.webapp.beans.DisplayMessage", "Please log in to authorize external app to access your profile.")
      redirect_to "/authenticate?" + URI.escape("afterLogin=" + servlet_request.request_uri + "?" + (servlet_request.query_string|| ""))
    end    
  end

  alias :login_required :authenticate_user_vivo


end
