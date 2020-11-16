require 'order_helper'

describe 'Order placement via Account'  do # :connected => true, :integration => true do
	let(:contract_type) { :stock }

	before(:all) { init_gateway }

	after(:all) do 
		remove_open_orders
		close_connection 
	end


	let( :jardine ){ IB::Stock.new symbol: 'J36', exchange: 'SGX' }  # trading hours: 2 - 10 am GMT, min-lot-size: 100

	let( :the_client ){  IB::Gateway.current.clients.detect{|y| y.account ==  ACCOUNT} } 

	context '(Not) Placing orders', :slow => true do
		before(:each) do
			gw = IB::Gateway.current
			gw.tws.clear_received   # just in case ...
		end
		# note:  if the tests don't pass, cancel all orders maually and run again  (/examples/canccel_orders)
		it "wrong order" do
			the_order=  IB::Limit.order action: :buy, size: 10, :limit_price =>  0.453 # non-acceptable price
			local_id = the_client.place contract: jardine, order: the_order
			expect( local_id ).to be_nil
			expect( the_client.orders ).to have(1).entry
			expect( the_client.orders.first.order_states ).to have_at_least(1).entry
#			puts the_client.orders.first.order_states.last.inspect
			expect( the_client.orders.first.order_states.last.status).to eq 'New'
			expect( the_client.orders.first.order_states.last.filled).to be_zero
		end
		it "order too small" do
			the_order=  IB::Limit.order action: :buy, size: 10, :limit_price =>  20 # acceptable price
			expect( should_log /The price does not conform to the minimum price variation/ ).to be_truthy
			local_id = the_client.place contract: jardine, order: the_order
			expect( local_id ).to be_nil
			expect( the_client.orders ).to have(1).entry
			expect( the_client.orders.first.order_states ).to have_at_least(1).entry
			expect( the_client.orders.first.order_states.last.status).to eq 'New'
			expect( the_client.orders.first.order_states.last.filled).to be_zero
		end


	end
	

end # describe
