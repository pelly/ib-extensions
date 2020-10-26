=begin
request con_id for a given  IB::Contract

returns the con_id's

After calling the helper-function, the fetched ContractDetail-Messages are still present in received-buffer 
=end

def request_con_id  contract: SAMPLE

		ib =  IB::Connection.current
		ib.clear_received
		raise 'Unable to verify contract, no connection' unless ib && ib.connected?

		ib.send_message :RequestContractDetails, contract: contract
		ib.wait_for :ContractDetailsEnd

		ib.received[:ContractData].contract.map &:con_id  # return an array of con_id's

end

RSpec.shared_examples 'a complete Contract Object' do 
	subject{ the_contract }
	it_behaves_like 'a valid Contract Object'
  it { is_expected.to be_an IB::Contract }
	its( :contract_detail ){ is_expected.to be_a  IB::ContractDetail }
	its( :primary_exchange){ is_expected.to be_a String }
end
RSpec.shared_examples 'a valid Contract Object' do 
#	subject{ the_contract }
  it { is_expected.to be_an IB::Contract }
	its( :con_id          ){ is_expected.to be_empty.or be_a(Numeric) }
	its( :contract_detail ){ is_expected.to be_nil.or be_a(IB::ContractDetail) }
  its( :symbol          ){ is_expected.to be_a String }
  its( :local_symbol    ){ is_expected.to be_a String }
  its( :currency        ){ is_expected.to be_a String }
	its( :sec_type        ){ is_expected.to be_a(Symbol).and satisfy { |sec_type| IB::SECURITY_TYPES.values.include?(sec_type) } }
  its( :trading_class   ){ is_expected.to be_a String }
	its( :exchange        ){ is_expected.to be_a String }
	its( :primary_exchange){ is_expected.to be_nil.or be_a(String) }
end
RSpec.shared_examples 'ContractData Message' do 
	subject{ the_message }
  it { is_expected.to be_an IB::Messages::Incoming::ContractData }
	its( :contract         ){ is_expected.to be_a  IB::Contract }
	its( :contract_details ){ is_expected.to be_a  IB::ContractDetail }
  its( :message_id       ){ is_expected.to eq 10 }
  its( :version          ){ is_expected.to eq 8 }
	its( :buffer           ){ is_expected.to be_empty }

  it 'has class accessors as well' do
    expect( subject.class.message_id).to eq 10
    expect( subject.class.message_type).to eq :ContractData
  end

end

shared_examples_for "correctly query's the tws" do
	
		it "query_contract does not raise an error" do
			expect { contract.query_contract }.not_to raise_error
		end


		it "query_contract resets con_id" do
			query_contract =  contract.query_contract 
			unless contract.sec_type.nil?
			expect( contract.con_id ).to be_zero 
			end
		end
		it "verify does intitialize con_id and contract_detail " do
			contract.verify do | c |
			expect( c.con_id ).not_to be_zero
			expect( c.contract_detail).to be_a IB::ContractDetail
			end
		end 

		it "verify returns a number" do
		  expect( contract.verify ).to be > 0
		end

		
end
shared_examples_for "invalid query of tws"  do
	
		it "does not verify " do
		  contract.verify
		expect(  should_log /Not a valid Contract/ ).to be_truthy
		end

		it "returns zero" do
		  expect( contract.verify ).to be_zero
		end
		
end
