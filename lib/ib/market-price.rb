
module CoreExtensions
  module Array
    module DuplicatesCounter
      def count_duplicates
        self.each_with_object(Hash.new(0)) { |element, counter| counter[element] += 1 }.sort_by{|k,v| -v}.to_h
      end
    end
  end
end

Array.include CoreExtensions::Array::DuplicatesCounter
module IB


	
 class Contract
# Ask for the Market-Price 
# 
# For valid contracts, either bid/ask or last_price and close_price are transmitted.
# 
# If last_price is received, its returned. 
# If not, midpoint (bid+ask/2) is used. Else the closing price will be returned.
# 
# Any  value (even 0.0) which is stored in IB::Contract.misc indicates that the contract is 
# accepted by `place_order`.
# 
# The result can be customized by a provided block.
# 
# 	IB::Symbols::Stocks.sie.market_price{ |x| x }
# 	-> {"bid"=>0.10142e3, "ask"=>0.10144e3, "last"=>0.10142e3, "close"=>0.10172e3}
#  
# 
#  Raw-data are stored in the _bars_-attribute of IB::Contract 
#  (volatile, ie. data are not preserved when the Object is copied)
#  
#Example:  IB::Stock.new(symbol: :ge).market_price
# returns the current market-price
#
#Example:  IB::Stock.new(symbol: :ge).market_price(thread: true).join 
# assigns IB::Symbols.sie.misc with the value of the :last (or delayed_last) TickPrice-Message
# and returns this value, too
#
#Raises IB::Error 
#  if no Marketdata Subscription is present and delayed: false is specified
#  
#
#  Solutions: Catch the Error and retry with delayed: true
#
#             if that fails use alternative exchanges  (look to Contract.valid_exchanges)
#
			def market_price delayed:  true, thread: false

				tws=  Connection.current 		 # get the initialized ib-ruby instance
				the_id , the_price =  nil, nil
				tickdata =  Hash.new
				# define requested tick-attributes
				last, close, bid, ask	 = 	[ [ :delayed_last , :last_price ] , [:delayed_close , :close_price ],
																[  :delayed_bid , :bid_price ], [  :delayed_ask , :ask_price ]] 
				request_data_type =  delayed ? :frozen_delayed :  :frozen

				tws.send_message :RequestMarketDataType, :market_data_type =>  IB::MARKET_DATA_TYPES.rassoc( request_data_type).first

				#keep the method-call running until the request finished
				#and cancel subscriptions to the message handler
				# method returns the (running) thread
				th = Thread.new do
					finalize, raise_delay_alert = false, false
					s_id = tws.subscribe(:TickSnapshotEnd){|x| finalize = true if x.ticker_id == the_id }

				e_id = tws.subscribe(:Alert){|x| raise_delay_alert = true if x.code == 354 && x.error_id == the_id } 
					# TWS Error 354: Requested market data is not subscribed.
#					r_id = tws.subscribe(:TickRequestParameters) {|x| } # raise_snapshot_alert =  true  if x.snapshot_permissions.to_i.zero?  && x.ticker_id == the_id  }
								 
					# subscribe to TickPrices
					sub_id = tws.subscribe(:TickPrice ) do |msg| #, :TickSize,  :TickGeneric, :TickOption) do |msg|
						[last,close,bid,ask].each do |x| 
							tickdata[x] = msg.the_data[:price] if x.include?( IB::TICK_TYPES[ msg.the_data[:tick_type]]) 
							#  fast exit condition
							finalize = true if tickdata.size ==4  || ( tickdata[bid].present? && tickdata[ask].present? )  
						end if  msg.ticker_id == the_id 
					end
					# initialize »the_id« that is used to identify the received tick messages
					# by firing the market data request
					the_id = tws.send_message :RequestMarketData,  contract: self , snapshot: true 

					# todo implement config-feature to set timeout in configuration   (DRY-Feature)
					# Alternative zu Timeout
					# Thread.new do 
					#     i=0; loop{ i+=1; sleep 0.1; break if finalize || i > 1000 }

					i=0; 
					loop{ i+=1; break if i > 1000 || finalize || raise_delay_alert; sleep 0.05 } 
					tws.unsubscribe sub_id, s_id, e_id 
					# reduce :close_price delayed_close  to close a.s.o 
					if raise_delay_alert && !delayed
						error "No Marketdata Subscription, use delayed data <-- #{to_human}" 
			#		elsif raise_snapshot_alert
			#			error "No Snapshot Permissions, try alternative exchange  <-- #{to_human}"
					elsif i <= 1000
						tz = -> (z){ z.map{|y| y.to_s.split('_')}.flatten.count_duplicates.max_by{|k,v| v}.first.to_sym}
						data =  tickdata.map{|x,y| [tz[x],y]}.to_h
						valid_data = ->(d){ !(d.to_i.zero? || d.to_i == -1) }
						self.bars << data											#  store raw data in bars
						the_price = if block_given? 
													yield data 
													# yields {:bid=>0.10142e3, :ask=>0.10144e3, :last=>0.10142e3, :close=>0.10172e3}
												else # behavior if no block is provided
													if valid_data[data[:last]]
														data[:last] 
													elsif valid_data[data[:bid]]
														(data[:bid]+data[:ask])/2
													elsif data[:close].present? 
														data[:close]
													else
														nil
													end
												end
						self.misc =  the_price if thread  # store internally if in thread modus
					else   #  i > 1000
						tws.logger.info{ "#{to_human} --> No Marketdata received " }
					end

				end
				if thread
					th		# return thread
				else
					th.join
					the_price	# return 
				end
			end #

 end
end
