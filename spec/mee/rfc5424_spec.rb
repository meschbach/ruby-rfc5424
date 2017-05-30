# vim: set ft=ruby tabstop=2 softtabstop=2 shiftwidth=2 autoindent noexpandtab:
require 'spec_helper'
require "syslog/parser"
require 'syslog'

class CapturingTransport
	attr_accessor :last_frame, :all_frames
	def initialize( )
		self.all_frames = []
	end

	def send_frame( frame )
		self.last_frame = frame
		self.all_frames.push( frame )
	end
end

describe MEE::RFC5424 do
  it 'has a version number' do
    expect(MEE::RFC5424::VERSION).not_to be nil
  end

	describe "given a host and a process name" do
		host = "example.host.invalid"
		proc_name = "cabaret"
		target_date = DateTime.parse("2003-10-11t22:14:15.003z")

		before do
			meta = MEE::RFC5424::Meta.new( :host => host, :name => proc_name )
			text = meta.header( :when => target_date )
			parser = Syslog::Parser.new
			@result = parser.parse( text )
		end

		it "has the correct host" do; expect( @result.hostname ).to eq( host ); end
		it "has correct process name" do; expect( @result.app_name ).to eq( proc_name ); end
		it "uses facility user 0" do; expect( @result.facility ).to eq( Syslog::Facility::LOG_USER ) ; end
		it "at severity info" do; expect( @result.severity ).to eq( Syslog::LOG_INFO ) ; end
		it "logs the procid" do; expect( @result.procid ).to eq( String( Process.pid ) ); end
		it "has the correct time" do; expect( DateTime.parse( @result.timestamp.strftime("%FT%T.%3NZ" ) ) ).to eq( target_date ) ; end
	end

	describe "Newline nontransparent framing" do
		before do
			@transport = CapturingTransport.new
			client = MEE::RFC5424::SyslogClient.new( @transport, :framing => MEE::RFC5424::NewLineFraming.new() )
			client.message( "frame 0" )
			client.message( "frame 1" )
		end

		it "yeilds multiple frames" do
			expect( @transport.all_frames.length ).to eq(2)
		end

		it "appends new line" do
			expect( @transport.last_frame[-1] ).to eq( "\n" )
		end
	end

	describe "Octet Counting Framing" do
		before do
			@transport = CapturingTransport.new
			client = MEE::RFC5424::SyslogClient.new( @transport, :framing => MEE::RFC5424::OctetFraming.new() )
			client.meta.host = "test.host.at.domain.invalid"
			client.message( "frame 0" )
			client.message( "frame 1" )
			client.message( "\u1F600\u1F601" )
		end

		it "yeilds multiple frames" do
			expect( @transport.all_frames.length ).to eq(3)
		end

		it "doesn't append new line" do
			expect( @transport.last_frame[-1] ).not_to eq( "\n" )
		end

		it "starts with message size" do
			expect( @transport.last_frame.split(" ")[0] ).to eq( "85" )
		end
	end

	if ENV['SYSLOG_TCP_HOST'] and ENV['SYSLOG_TCP_PORT']
		describe "TCP tests" do
			it "Sends messages" do
				target = MEE::RFC5424.tcp( ENV['SYSLOG_TCP_HOST'], ENV['SYSLOG_TCP_PORT'] )
				target.name = "test-tcp-integ"
				target.info { "There is still time for tea" }
				target.error { "\U+1F600" }
			end
		end
	end

	if ENV['SYSLOG_TLS_HOST'] and ENV['SYSLOG_TLS_PORT']
		describe "TLS transport" do
			before do
				@target = MEE::RFC5424.tls( ENV['SYSLOG_TLS_HOST'], ENV['SYSLOG_TLS_PORT'] )
				@target.name = "test-tls-integ"
			end

			it "sends messages" do
				@target.info { "Day of the dead" }
				@target.error { "Going to loose my head" }
			end

			it "can send UTF-8 data" do
				@target.error { "\u2764" }
			end
		end
	end
end
