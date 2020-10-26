module IB

    module   StockSpread
      
      extend SpreadPrototype
			class << self

				#  Fabricate a StockSpread from Scratch
				#  -----------------------------------------
				# 
				#  
				#
				#   Call with 
				#   IB::StockSpread.fabricate  'GE','F', ratio:[1,-2]
				#
				#   or
				#   IB::StockSpread.fabricate  IB::Stock.new(symbol:'GE'), 'F', ratio:[1,-2]
				#
				def  fabricate *underlying,  ratio: [1,-1]
					#
					are_stocks =  ->{ underlying.all?{|y| y.is_a? IB::Stock} }
					underlying.map!{|y| y.is_a?( IB::Stock ) ? y : IB::Stock.new( symbol: y )}
					error "only spreads with two underyings of type »IB::Stock« are supported" unless underlying.size==2 && are_stocks[]
					verified_legs = underlying.map{|c| c.verify!.essential} # ensure, that con_id is present

					initialize_spread( verified_legs.first ) do | the_spread |
						c_l = verified_legs.zip(ratio).map do |l,r| 
						action = r >0 ?  :buy : :sell
						the_spread.add_leg  l,  action: action,  ratio: r.abs 
					end
					the_spread.description =  the_description( the_spread )
					the_spread.symbol = verified_legs.map( &:symbol ).sort.join(",")  # alphabetical order

					end
				end

				def the_description spread
					info=  spread.legs.map( &:symbol ).zip(spread.combo_legs.map( &:weight ))
					"<StockSpread #{info.map{|c| c.join(":")}.join(" , ")} (#{spread.currency} )>"

				end

				# always route a order as NonGuaranteed 
				def order_requirements
					{	combo_params:  ['NonGuaranteed', true] }
				end

			end # class
		end	# module 
end  # module ib
