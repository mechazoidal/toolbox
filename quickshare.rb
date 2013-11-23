#!env ruby

require 'thin'
require 'rack'
#require 'socket'
require 'trollop'

# inspired by: http://code.joejag.com/2011/start-a-web-server-from-your-pwd-using-ruby-and-thin/

opts = Trollop::options do
  opt :path, "path of files that should be hosted", :default=>Dir.pwd, :type=>:string
  #opt :hostname, "hostname", :default=>IPSocket.getaddress(Socket.gethostname)
  opt :hostname, "hostname", :default=>"localhost"
  opt :socket, "socket to host on", :default=>7777
end

Thin::Server.start(opts[:hostname], opts[:socket]) do
  use Rack::CommonLogger
  run Rack::Directory.new(opts[:path])
end
