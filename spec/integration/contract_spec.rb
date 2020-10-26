require 'main_helper'
require 'contract_helper'  # provides request_con_id


RSpec.describe IB::Contract do

  # uses the SAMPLE Contract specified in spec_helper 

  context IB::Stock, :connected => true do
    before(:all) do
		  establish_connection
      ib = IB::Connection.current
			ib.send_message :RequestContractDetails, contract: IB::Symbols::Stocks.sie
      ib.wait_for :ContractDetailsEnd
    end

    after(:all) { close_connection }

	  context "read recieved buffer" do	
		subject { IB::Connection.current.received[:ContractData].last.contract }
		it "inspect" do
			puts   IB::Connection.current.received.keys
			puts  IB::Connection.current.received[:ContractData].inspect
		end

		it_behaves_like 'a valid Contract Object' #do
#			let( :the_contract ){ SAMPLE }
		end


	 context '#merge' do
		 subject{ IB::Symbols::Stocks.sie.merge( symbol: 'ALV' ) }  # returns a new object
		it_behaves_like 'a valid Contract Object' 
		 its( :symbol )         { is_expected.to eq 'ALV' }
		 its( :con_id )         { is_expected.to be_zero }
		 its( :contract_detail ){ is_expected.to be_nil }

		 it "returns a new object" do
			 source=  IB::Symbols::Stocks.sie
			 dest = source.merge( symbol: 'ALV' ) 

			 expect( source.object_id).not_to eq dest.object_id
		 end
	 end




	end
end # describe IB::Messages:Incoming

