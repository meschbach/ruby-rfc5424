# vim: set ft=ruby tabstop=2 softtabstop=2 shiftwidth=2 autoindent noexpandtab:
require_relative "rfc5424/version"
require 'syslog'

require 'logger'
require 'openssl'
require 'socket'
require 'time'

module MEE
  module RFC5424
		class Meta
			attr_accessor :host, :proc_name, :facility, :pid

			def initialize( props = {})
				self.host = props[:host] || Socket.gethostname
				self.proc_name = props[:name] || "ruby"
				self.facility = Syslog::Facility::LOG_USER
				self.pid = Process.pid
			end

			def header( params = {} )
				severity = params[:severity] || Syslog::LOG_INFO
				when_date = (params[:when] || DateTime.now).new_offset( 0 )
				formatted_when = when_date.strftime("%FT%T.%3NZ")
				priority = (facility * 8) + severity
				"<#{priority}>1 #{formatted_when} #{self.host} #{proc_name} #{self.pid} - - \xEF\xBB\xBF"
			end
		end

		class NewLineFraming
			def frame( input )
				input + "\n"
			end
		end

		class OctetFraming
			def frame( input )
				length = input.bytesize
				"" + length.to_s + " " + input
			end
		end

		class SyslogClient
			attr_accessor :framing, :transport, :meta

			def initialize( transport, opts = {} )
				self.transport = transport
				self.framing = opts[:framing] || OctetFraming.new
				self.meta = Meta.new
			end

			def message( body )
				header = meta.header
				whole_message = header + body
				wire_payload = framing.frame( whole_message )
				transport.send_frame( wire_payload )
			end
		end

		class SocketTransport
			attr_accessor :socket
			def initialize( socket )
				self.socket = socket
			end

			def send_frame( frame )
				socket.write( frame )
			end
		end

		class LoggerProtocolAdapter < Logger
			attr_accessor :protocol

			def initialize( protocol )
				super(nil)
				@logdev = self
				self.protocol = protocol
			end

			def write( entry )
				self.protocol.message( entry )
			end

			def name; protocol.meta.proc_name; end
			def name=( new_value ) ; protocol.meta.proc_name = new_value; end
		end

		def self.tcp( host, port )
			target = TCPSocket.new( host, port )
			protocol = SyslogClient.new( SocketTransport.new( target ) )
			LoggerProtocolAdapter.new( protocol )
		end

		def self.tls( host, port )
			raw_transport = TCPSocket.new( host, port )
			secure_transport = OpenSSL::SSL::SSLSocket.new raw_transport
			secure_transport.connect
			protocol = SyslogClient.new( SocketTransport.new( secure_transport )  )
			LoggerProtocolAdapter.new( protocol )
		end
  end
end

