require 'combo_helper'

RSpec.describe "IB::Calendar" do
	let ( :the_option ){ IB::Option.new  symbol: :Estx50, strike: 4000, right: :call,  expiry: IB::Symbols::Futures.next_expiry, trading_class: 'OESX' }
  before(:all) do
    establish_connection
			IB::Connection.current.subscribe( :Alert ){|y|  puts y.to_human }
  end

  after(:all) do
    close_connection
  end


	context "initialize with master-option" do
		subject { IB::Calendar.fabricate the_option,  the_option.expiry.to_i+1 }
		it{ is_expected.to be_a IB::Bag }
		it_behaves_like 'a valid Estx Combo'
		
			
	end

	context "initialize with underlying" , focus: true do
		subject{ IB::Calendar.build( from: IB::Symbols::Index.stoxx, 
																 strike: 4000, 
																 right: :put,
																 trading_class: 'OESX',
																 front:  IB::Symbols::Futures.next_expiry , 
																 back:  '-1m'
															 ) }

		it{ is_expected.to be_a IB::Spread }
		it_behaves_like 'a valid Estx Combo'
	end
	context "initialize with Future" do
		subject{ IB::Calendar.fabricate  IB::Symbols::Futures.zn, '3m' }

		it{ is_expected.to be_a IB::Spread }
		it_behaves_like 'a valid ZN-FUT Combo'
	end
end
