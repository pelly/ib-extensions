require 'combo_helper'
STRIKE =  3200
RSpec.describe "IB::Straddle" do
	let ( :the_option ){ IB::Option.new  symbol: :Estx50, right: :put, strike: STRIKE, expiry: IB::Symbols::Futures.next_expiry }
	let ( :the_bag ){ IB::Symbols::Combo::stoxx_straddle }
  before(:all) do
    establish_connection 
    IB::Connection.current.subscribe( :Alert ){|y|  puts y.to_human } 
  end

  after(:all) do
    close_connection
  end


	context "fabricate with master-option" do
		subject { IB::Straddle.fabricate IB::Symbols::Options.estx.merge( strike: STRIKE ) }
		it{ is_expected.to be_a IB::Bag }
		it_behaves_like 'a valid Estx Combo'
		
			
	end

	context "build with index underlying" do
		subject{ IB::Straddle.build from: IB::Symbols::Index.stoxx, strike: STRIKE , expiry: IB::Symbols::Futures.next_expiry  }

		it{ is_expected.to be_a IB::Spread  }
		it_behaves_like 'a valid Estx Combo'
	end

	context "build with future underlying" do
		subject{ IB::Straddle.build from: IB::Symbols::Futures.es, strike: 2600 , expiry: IB::Symbols::Futures.next_expiry, trading_class: 'ES'  }

		it{ is_expected.to be_a IB::Spread  }
		it_behaves_like 'a valid ES-FUT Combo'
	end

	context "fabricate with stock underlying", focus: true do
		subject{ IB::Straddle.fabricate atm_option( IB::Symbols::Stocks.wfc)  }

		it{ is_expected.to be_a IB::Spread  }
		it_behaves_like 'a valid wfc-stock Combo'
	end

	context "build with option"  do
		subject{ IB::Straddle.build from: the_option, strike: STRIKE }

		it{ is_expected.to be_a IB::Spread }
		it_behaves_like 'a valid Estx Combo'
	end
end
