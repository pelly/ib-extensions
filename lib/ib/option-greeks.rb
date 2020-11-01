module IB


	
 class Option
# Ask for the Greeks and implied Vola 
# 
# The result can be customized by a provided block.
# 
# 	IB::Symbols::Options.aapl.greeks{ |x| x }
# 	-> {"bid"=>0.10142e3, "ask"=>0.10144e3, "last"=>0.10142e3, "close"=>0.10172e3}
#  
#   Possible values for Parameter :what --> :all :model, :bid, :ask, :bidask, :last
# 
			def greeks delayed:  true, what: :model, thread: false

				tws=  Connection.current 		 # get the initialized ib-ruby instance
				the_id  =  nil
				tickdata = []
				# define requested tick-attributes
				request_data_type = IB::MARKET_DATA_TYPES.rassoc( delayed ? :frozen_delayed :  :frozen ).first
				# possible types = 	[ [ :delayed_model_option , :model_option ] , [:delayed_last_option , :last_option ],
				# [ :delayed_bid_option , :bid_option ], [ :delayed_ask_option , :ask_option ]	]											  	        
				tws.send_message :RequestMarketDataType, :market_data_type =>  request_data_type

				#keep the method-call running until the request finished
				#and cancel subscriptions to the message handler
				# method returns the (running) thread
				th = Thread.new do
					finalize= false
					# subscribe to TickPrices
					s_id = tws.subscribe(:TickSnapshotEnd) { |msg|	finalize = true	if msg.ticker_id == the_id }
					e_id = tws.subscribe(:Alert){|x|  finalize = true if [200,353].include?( x.code) && x.error_id == the_id } 
					# TWS Error 200: No security definition has been found for the request
					# TWS Error 354: Requested market data is not subscribed.
					sub_id = tws.subscribe(:TickOption ) do |msg| #, :TickSize,  :TickGeneric  do |msg|
						if  msg.ticker_id == the_id
							case what.to_s
							when 'all'
								tickdata << msg   # unconditional
							when /bid/
								tickdata << msg  if msg.type =~ /bid/
							when /ask/
								tickdata << msg  if msg.type =~ /ask/
							when /last/
								tickdata << msg  if msg.type =~ /last/
							when /model/
								tickdata << msg  if msg.type =~ /model/
							end
							tickdata =  tickdata &.first unless [:bidask, :all].include? what
							finalize = true if tickdata.is_a?  IB::Messages::Incoming::TickOption || tickdata.size == 2 && what== :bidask || tickdata.size == 4 && what == :all
						end

					end
					# initialize »the_id« that is used to identify the received tick messages
					# by firing the market data request
					the_id = tws.send_message :RequestMarketData,  contract: self , snapshot: true 

					begin
						# todo implement config-feature to set timeout in configuration   (DRY-Feature)
						Timeout::timeout(5) do   # max 5 sec.
							loop{ break if finalize ; sleep 0.05 } 
							# reduce :close_price delayed_close  to close a.s.o 
							self.misc =  tickdata if thread  # store internally if in thread modus
						end
					rescue Timeout::Error
						Connection.logger.info{ "#{to_human} --> No Marketdata received " }
					end
					tws.unsubscribe sub_id, s_id, e_id
				end
				if thread
					th		# return thread
				else
					th.join
					tickdata	# return 
				end
			end #

 end
end
