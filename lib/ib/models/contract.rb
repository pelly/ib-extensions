require "ib/model"
module IB
  class  Contract < IB::Model
    def included_in? account
      self if   account.locate_contract(con_id)
    end

    def portfolio_value account
      if con_id.to_i > 0
        account.portfolio_values.detect{|x| x.contract.con_id == con_id }
      else
        account.portfolio_values.detect{|x| x.contract == self }
      end
    end
  end
end
