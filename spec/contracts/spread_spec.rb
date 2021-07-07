require 'combo_helper'

RSpec.describe "IB::Spread" do
  let ( :the_option ){ IB::Option.new  symbol: :Estx50, strike: 4000, right: :call,  expiry: IB::Symbols::Futures.next_expiry,  trading_class: 'OESX', exchange: 'DTB'}
  let( :the_spread ) { IB::Calendar.fabricate IB::Symbols::Futures.nq, '3m' }

  before(:all) do
    establish_connection
    IB::Connection.current.subscribe( :Alert ){|y| puts y.to_human }
  end

  after(:all) do
    close_connection
  end


	context "initialize by fabrication" do
	
		subject{ the_spread }
		it{ is_expected.to be_a IB::Bag }
		it_behaves_like 'a valid NQ-FUT Combo'

    it "has proper combo-legs" do
      expect( subject.combo_legs.first.side ).to eq  :buy
      expect( subject.combo_legs.last.side ).to eq :sell
    end
	end

#	context "serialize the spread" do 
#				subject { the_spread.serialize_rabbit }
#
#				its(:keys){ should eq ["Spread", "legs", "combo_legs", 'misc'] }
#
#				it "serializes the contract" do
#					expect( IB::Spread.build_from_json( subject)).to eq the_spread 
#				end
#
#
#				it "json acts as valid transport medium" do
#					json_medium =  subject.to_json
#					expect( IB::Spread.build_from_json( JSON.parse( json_medium ))).to eq the_spread 
#				end
#
#	end

	context "leg management"   do
		subject { the_spread }

		its( :legs ){ is_expected.to have(2).elements }

		it "add a leg" do
		expect{ subject.add_leg( the_option  )  }.to  change{ subject.legs.size }.by(1)
		end

		it "remove a leg" do
		# non existing leg
		expect{ subject.remove_leg( the_option  )  }.not_to  change{ subject.legs.size }

#		subject.add_leg( the_option  ) 
		expect{ subject.remove_leg( 0 )  }.to  change{ subject.legs.size }.by(-1)
		end
	end

end
