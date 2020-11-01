
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
# assigns IB::Symbols.sie.misc with the value of the :last (or delayed_last) TickPrice-Message
# and returns this value, too
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
					finalize= false
					# subscribe to TickPrices
					s_id = tws.subscribe(:TickSnapshotEnd) { |msg|	finalize = true	if msg.ticker_id == the_id }
					e_id = tws.subscribe(:Alert){|x|  finalize = true if x.code == 354 && x.error_id == the_id } 
					# TWS Error 354: Requested market data is not subscribed.
					sub_id = tws.subscribe(:TickPrice ) do |msg| #, :TickSize,  :TickGeneric, :TickOption) do |msg|
						[last,close,bid,ask].each do |x| 
							tickdata[x] = msg.the_data[:price] if x.include?( IB::TICK_TYPES[ msg.the_data[:tick_type]]) 
							finalize = true if tickdata.size ==4  || ( tickdata[bid].present? && tickdata[ask].present? )  
						end if  msg.ticker_id == the_id 
					end
					# initialize »the_id« that is used to identify the received tick messages
					# by firing the market data request
					the_id = tws.send_message :RequestMarketData,  contract: self , snapshot: true 

					begin
						# todo implement config-feature to set timeout in configuration   (DRY-Feature)
						Timeout::timeout(5) do   # max 5 sec.
							loop{ break if finalize ; sleep 0.1 } 
							# reduce :close_price delayed_close  to close a.s.o 
							tz = -> (z){ z.map{|y| y.to_s.split('_')}.flatten.count_duplicates.max_by{|k,v| v}.first.to_sym}
							data =  tickdata.map{|x,y| [tz[x],y]}.to_h
							valid_data = ->(d){ !(d.to_i.zero? || d.to_i == -1) }
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
					the_price	# return 
				end
			end #

 end
end
