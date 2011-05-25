require 'sinatra'
require "sinatra/reloader" if development?

require 'rest_client'
require 'json/pure'
require 'pp'
require 'erb'

gem 'emk-sinatra-url-for'
require 'sinatra/url_for'

include_class 'javax.servlet.http.HttpServletResponse'

if defined?(JRuby::Rack::Capture)
  helpers do
    include JRuby::Rack::Capture::Base
    include JRuby::Rack::Capture::RubyGems
    include JRuby::Rack::Capture::Bundler
    include JRuby::Rack::Capture::JRubyRackConfig
    include JRuby::Rack::Capture::Environment
    include JRuby::Rack::Capture::JavaEnvironment
    include JRuby::Rack::Capture::LoadPath
    include DemoCaptureHelper
    include FileStoreHelper
  end
else
 # helpers DemoDummyHelper
end


get '/' do
  erb :root
end

post '/body' do
  res = "Content-Type was: #{request.content_type.inspect}\n"
  body = request.body.read
  if body.empty?
    status 400
    res << "Post body empty\n"
  else
    res << "Post body was:\n#{body}\n"
  end
end

get %r'.*/info' do
  content_type 'text/plain; charset=utf-8'
  erb :info
end

get '/jruby/env' do
  content_type 'text/plain; charset=utf-8'
  capture
  store
  output.string
end


# Basic wrapper around the CrossRef SIGG query service
get '/jruby/bibliosearch' do

  @resultlist = [] # for storing results from bibliosearch

  if params[:query]  
    # Look up bibliographic metadata via CrossRef service
    sigg_url = 'http://crossref.org/sigg/sigg/FindWorks'
  
    puts "Sending query '#{params[:query]}' to SIGG " + sigg_url
    response = RestClient.get sigg_url, {:accept => :json,
                                         :params => {:version => 1,
                                                     :access  => "gthorisson%40gmail.com",
                                                     :format  => "json",
                                                     :op      => "AND",
                                                     :expression => params[:query]}}
  
    # TEMPORARY!! create array from retrieved JSON and pass this to a template for rendering
    #@resultlist = JSON.parse response.to_str
    return response.to_str
  end
  
  #return erb :listbibliosearchresults
  
  
  # Return JSON string direct ly, for use in client-side UI
  #res =  "\nFetching metadata via " + sigg_url
  #res << "\n\n"
  #res << response.to_str
  # return res  
end

# Wrapper around the CrossRef metadata retrieval service
get '/jruby/bibliofetch' do
  
  url = 'http://dx.doi.org/'
  # For reach DOI passed in, fetch full metadata from CrossRef
  puts "Got DOI list: #{params['doi']}"
  @bibliolist = []
 # doi_list = params['doi']
  #if doi_list
   # doi_list.each do|doi|
      doi = params['doi']

      puts "retrieving metadata via #{url}#{doi}"
      begin
        response = RestClient.get url + doi, {:accept =>  "application/rdf+json"} #  "text/turtle"}
        #obj_from_json = JSON.parse(response.to_str)
        #@bibliolist.push(obj_from_json)
        return response.to_str
      rescue # try not blow up if the REST call doesn't return successfully
        puts "An error occurred when looking up #{doi}: #{$!}"
        # Return 404 and abort?
      end
 #   end
#  end
  
  # TEMPORARY: pass array w/ pub metadata to template for rendering
  #pp @bibliolist
  #puts "Got metadata for #{@bibliolist.length} pubs. Returning as JSON array to caller"
  #return erb :listbibliodetails
  #return @bibliolist

  
  # TODO: Hand biblio RDF on to harvester for matching against current contents of VIVO store,
  #       and then probably on to a separate controller which deals with that outcome and
  #       presenting that to the user.
  
end

get '/jruby/testfwd' do
  req = request.env["java.servlet_request"]
  puts "in /testfwd, req = #{req}"
  request.env.keys.sort.map do |key|
    puts "#{key} => #{request.env[key]}"
  end
  
  pp response
  content_type "text/html"

  forward_to "/jruby/env"
  #puts "getContentLength = " + req.getContentLength()
  # getRequestDispatcher(String urlpath)
  # public abstract void forward(ServletRequest request, ServletResponse response)
         # throws ServletException, IOException

end

def forward_to(url)
  puts "forwarding to servlet mapped to #{url}"
  servlet_request = request.env['java.servlet_request']
  dispatcher = servlet_request.getRequestDispatcher(url)
  servlet_response = HttpServletResponse.new()
  servlet_context = request.env['java.servlet_context']
  puts "dispatcher info: " + dispatcher.getInfo()
  puts "servlet_context = #{servlet_context}, testing API call: getContextPath=" + servlet_context.getContextPath
  puts "forwarding request #{servlet_request} + servlet_response #{servlet_response} to servlet handling #{url}, via dispatcher #{dispatcher}"   
  begin
    dispatcher.forward(servlet_request, servlet_response)
  rescue
    puts "exception caught: #{$!}"
  end
#  render_with_servlet_response do |response|
#    req.getRequestDispatcher(url).forward(servlet_request, response)
#  end
end

def render_with_servlet_response(&block)
  if block
    @performed_render = true
    response.headers['Forward'] = block
  end
end




# Wrapper around the PubMed query service
get '/jruby/api/bibliosearch/pubmed' do
  
end

# Wrapper around the PubMed metadata retrieval service
get '/api/bibliofetch/pubmed' do
  return "got params #{request.params[:id]}"

end



