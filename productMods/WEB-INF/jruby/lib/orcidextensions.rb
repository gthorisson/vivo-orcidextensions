#This code was created by ORCID as part of the VIVO Collaborative Research Projects Program.
#
#Author: Gudmundur A. Thorisson <gthorisson@gmail.com>
#
#See also https://github.com/gthorisson/vivo-orcidextensions
#
#
#THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
#ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
#WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
#FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
#DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
#SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
#CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
#OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
#OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


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
  
    #@resultlist = JSON.parse response.to_str
    return response.to_str
  end
  
  #return erb :listbibliosearchresults
end

# Wrapper around the CrossRef metadata retrieval service
get '/jruby/bibliofetch' do
  
  url = 'http://dx.doi.org/'
  # For reach DOI passed in, fetch full metadata from CrossRef
  puts "Got DOI list: #{params['doi']}"
  @bibliolist = []
  doi = params['doi']

  puts "retrieving metadata via #{url}#{doi}"
    begin
        response = RestClient.get url + doi, {:accept =>  "application/rdf+json"} #  "text/turtle"}
        #obj_from_json = JSON.parse(response.to_str)
        #@bibliolist.push(obj_from_json)
        return response.to_str
      rescue # try not blow up if the REST call doesn't return successfully
        puts "An error occurred when looking up #{doi}: #{$!}"
        # ToDo Return 404 and abort?
    end
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




# ToDo: Wrapper around the PubMed query service
get '/jruby/api/bibliosearch/pubmed' do
  
end

# ToDo: Wrapper around the PubMed metadata retrieval service
get '/api/bibliofetch/pubmed' do
  return "got params #{request.params[:id]}"

end



