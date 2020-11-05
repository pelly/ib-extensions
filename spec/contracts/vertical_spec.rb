require 'combo_helper'

RSpec.describe "IB::Vertical" do
  before(:all) do
    establish_connection
    IB::Connection.current.subscribe( :Alert ){|y|  puts y.to_human }
  end

  after(:all) do
    close_connection
  end


	context "fabricate with master-option" do
		subject { IB::Vertical.fabricate IB::Symbols::Options.stoxx , sell: 3200}
		it{ is_expected.to be_a IB::Bag }
		it_behaves_like 'a valid Estx Combo'
		
			
	end

	context "build with underlying"  do
		subject{ IB::Vertical.build from: IB::Symbols::Index.stoxx, buy: 3000, sell: 3200, expiry: IB::Symbols::Futures.next_expiry  }

		it{ is_expected.to be_a IB::Spread }
		it_behaves_like 'a valid Estx Combo'
	end
	context "build with option" do 
		subject{ IB::Vertical.build from: IB::Symbols::Options.stoxx, buy: 3200 }

		it{ is_expected.to be_a IB::Spread }
		it_behaves_like 'a valid Estx Combo'
	end
	context "build with Future" do
		subject{ IB::Vertical.build from: IB::Symbols::Futures.es, buy: 3200, sell: 3400 }

		it{ is_expected.to be_a IB::Spread }
		it_behaves_like 'a valid ES-FUT Combo'

	end
			
	context "fabricated with FutureOption" do
		subject do
			fo = IB::Vertical.build( from: IB::Symbols::Futures.es, buy: 3200, sell: 3400).legs.first
			IB::Vertical.fabricate fo, sell: 3400
    end
		it{ is_expected.to be_a IB::Spread }
		it_behaves_like 'a valid ES-FUT Combo'

	end
end
