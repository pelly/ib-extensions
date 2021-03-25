module IB
  class Option
    def roll expiry, strike
      if strike.to_i > 2000
        expiry, strike =  strike, expiry  # exchange values if input occurs in wrong direction
      end
      new_option =  Option.new( invariant_attributes.merge( con_id: nil, trading_class: '', last_trading_day: nil,
                                                            local_symbol: "",
                                                            expiry: expiry,  strike: strike ))
      n_o = new_option.verify.first   # get con_id

      target = IB::Spread.new exchange: exchange, symbol: symbol, currency: currency
      target.add_leg self, action:  :buy
      target.add_leg n_o, action: :sell
    rescue NoMethodError
      Connection.logger.error "Rolling not possible. #{new_option.to_human} could not be verified"
      nil
    end
  end
end
