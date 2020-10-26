require 'combo_helper'

RSpec.describe "IB::Butterfly" do
	let ( :the_option ){ IB::Symbols::Options.stoxx.merge( strike: 3300 ) }
	let ( :the_bag ){ IB::Symbols::Combo::stoxx_butterfly }
	before(:all) do
		establish_connection
		IB::Connection.current.subscribe( :Alert ){|y|  puts y.to_human }
	end

after(:all) do
	close_connection
end


context "initialize with master-option" , focus: true do
	subject { IB::Butterfly.fabricate(  the_option, back: the_option.strike - 50, front: the_option.strike + 50 )}
	it{ is_expected.to be_a IB::Spread }
	it_behaves_like 'a valid Estx Combo'


end

context "initialize with underlying" do
	subject{ IB::Butterfly.build( from: IB::Symbols::Index.stoxx, strike: 3000, front: 2950 , back: 3050 , trading_class: 'OESX' ) }

	it{ is_expected.to be_a IB::Spread }
	it_behaves_like 'a valid Estx Combo'
end
end
