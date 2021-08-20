module IB
  class Bag
    def included_in? account
      # iterate over combo-legs 
      # and return the bag if all con_id's are present in the account.contracts-map
      self if combo_legs.map do |c_l|
        account.locate_contract c_l.con_id
      end.count == combo_legs.count
    end

    # returns an array of portfolio-values 
    #
    def portfolio_value account
      combo_legs.map do | c_l |
        account.portfolio_values.detect{|x| x.contract.con_id ==  c_l.con_id}
      end
    end
  end
end
