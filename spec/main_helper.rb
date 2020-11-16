require 'spec_helper'
require 'thread'
require 'stringio'
require 'rspec/expectations'

## Logger helpers

def mock_logger
  @stdout = StringIO.new

  @logger = Logger.new(@stdout).tap do |logger|
    logger.formatter = proc do |level, time, prog, msg|
      "#{time.strftime('%H:%M:%S')} #{msg}\n"
    end
    logger.level = Logger::INFO
  end
end

def log_entries
  @stdout && @stdout.string.split(/\n/)
end


def should_log *patterns
  patterns.each do |pattern|
   expect( log_entries.any? { |entry| entry =~ pattern }).to be_truthy
  end
end

def should_not_log *patterns
  patterns.each do |pattern|
    expect( log_entries.any? { |entry| entry =~ pattern }).to be_falsey
  end
end


## Connection helpers
def establish_connection

  ib = IB::Connection.new OPTS[:connection].merge(:logger => mock_logger)
	if ib
		ib.wait_for :ManagedAccounts, 5

		raise "Unable to verify IB PAPER ACCOUNT" unless ib.received?(:ManagedAccounts)

		received = ib.received[:ManagedAccounts].first.accounts_list.split(',')
		unless received.include?(ACCOUNT)
			close_connection
			raise "Connected to wrong account #{received}, expected #{account}" 
		end
  OPTS[:account_verified] = true
	else
		raise "could not establish connection!"
	end
end

def init_gateway
  args= OPTS[:connection].slice(:port, :host, :client_id).merge(  serial_array: true,  logger: mock_logger)
	gw = IB::Gateway.new  args
  if gw
		if va = gw.clients.detect{|c| c.account == ACCOUNT }
			OPTS[:account_verified] = true
		else
			raise "Connected to wrong account #{gw.clients.map( &:to_human).join " "}, expected #{account}" 
		end
	else
		raise "could not establish connection!"
	end
rescue  IB::Error => e
	puts e.inspect
	nil

end


# Clear logs and message collector. Output may be silenced.
def clean_connection
	ib =  IB::Connection.current
	if ib
		if OPTS[:verbose]
			puts ib.received.map { |type, msg| [" #{type}:", msg.map(&:to_human)] }
			puts " Logs:", log_entries if @stdout
		end
		@stdout.string = '' if @stdout
		ib.clear_received 
	end
end

def close_connection
	ib =  IB::Connection.current
	if ib
		clean_connection 
		ib.close
	end
end
