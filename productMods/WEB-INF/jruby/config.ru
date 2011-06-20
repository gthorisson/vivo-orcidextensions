# -*- mode: ruby -*-

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


# Startup script for the Sinatra application which 


require 'rubygems'
require 'bundler/setup'

# Load modules from app subdirectory 
appdir = Dir.getwd + "/" + File.expand_path(File.dirname(__FILE__)).split("/").pop
puts "appdir = " + appdir
Dir.chdir(appdir)

require appdir + '/lib/helpers'
require appdir + '/lib/orcidextensions'


# Start Sinatra application
set :run, false
set :public, appdir +'/public'
set :views, appdir +'/views'
set :environment, :production
run Sinatra::Application
