module IB
  class Future
    # helper method to roll an existing future
    #
    # Argument is the expiry of the target-future.
    #

    def roll **args
      error "specify expiry to roll a future" if args.empty?
      args[:to] = args[:expiry] if args[:expiry].present?  && args[:expiry] =~ /[mwMW]$/
      args[:expiry]= IB::Spread.transform_distance( expiry, args.delete(:to  )) if args[:to].present?
      
      new_future =  merge( **args ).verify.first
      error "Cannot roll future; target is no IB::Contract" unless new_future.is_a? IB::Future
      target = IB::Spread.new exchange: exchange, symbol: symbol, currency: currency
      target.add_leg self, action:  :buy
      target.add_leg new_future, action: :sell
    end
  end
end
