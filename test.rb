require 'socket'

class Client
	def initialize(av)
		begin
			@file = File.open(av[0])
		rescue
			raise ArgumentError, "Missing file #{av[0]}"
		end
		begin
			@client = TCPSocket.open(av[1], av[2])
		rescue
			raise ArgumentError, "Invalid host or port #{av[1]}:#{av[2]}"
		end
	end
	
	def send_request
		is_finish_header = false
		is_chunked = false
		@file.each_line do |line|
			if @file.eof? && (!is_finish_header || is_chunked)
				@client.print line.strip + "\r\n\r\n"
			elsif is_finish_header && !is_chunked
				@client.print line
			else
				@client.print line.strip + "\r\n"
			end
			if line.strip.length == 0
				is_finish_header = true
			end
			if line.include?("chunked")
				is_chunked = true
			end
			sleep(0.2);
		end
	end
	
	def recieve_response
		response = ""
		while (line = @client.gets)
			response += line
		end
		header = response[0, response.index("\r\n\r\n")]
		puts header
	end
	
	def close_all
		@file.close
		@client.close
	end
end

if __FILE__ == $PROGRAM_NAME
	if ARGV.length < 3
		puts "Usage: ruby test.rb [file] [host] [port]"
		return
	end

	begin
		client = Client.new(ARGV)
		client.send_request
		client.recieve_response
		client.close_all
	rescue ArgumentError => e
		puts "#{e}"
	end
end
