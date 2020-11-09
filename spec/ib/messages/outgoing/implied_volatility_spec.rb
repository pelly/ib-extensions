require 'main_helper'

shared_examples_for 'TickOption message' do
  it { is_expected.to be_an IB::Messages::Incoming::TickOptionComputation }
  its(:message_type) { is_expected.to eq :TickOption}
  its(:message_id) { is_expected.to eq 21 }
	its(:ticker_id) {is_expected.to eq 123}
	its( :buffer  ){ is_expected.to be_empty }

  it 'has class accessors as well' do
    expect( subject.class.message_id).to eq 21 
    expect( subject.class.message_type).to eq :TickOption
  end
end
####  NOT FINISHED ####
RSpec.describe IB::Messages::Incoming::TickOption do

  context 'Simulated Response from TWS' do

    subject do
         IB::Messages::Outgoing::RequestImpliedVolatility.new
					["954", "3", "234",
					"", "GE", "OPT", "20190118", "20.0", "C", "100", "SMART", 
					"", "USD", "", "", "0", "", "", "0", "", "\""]
		end

		it_behaves_like 'TickOption message'
		
  end

  context 'Message received from IB', :connected => true , focus: true do
##
    before(:all) do
			establish_connection
      @ib = IB::Connection.current
			## this only works if :under_price is set to a reasonable value, eg market_price +/- 10 %
			@ib.send_message :RequestImpliedVolatility, request_id: 123, contract: IB::Symbols::Options.aapl.verify.first,
								:under_price => 115, option_price: 8 

      @ib.wait_for :TickOption
    end

    after(:all) { close_connection }

    subject { @ib.received[:TickOption].first }
		 
    it_behaves_like 'TickOption message'
		its( :option_price ){ is_expected.to eq 8 }
		its( :under_price ){ is_expected.to eq 115 }

		its( :implied_volatility ){ is_expected.to  be_between(0.8, 0.9) }
  end #
end # describe IB::Messages:Incoming
