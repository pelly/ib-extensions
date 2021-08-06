
* lib/gateway.rb
	* rename `active_accounts` to `clients`  
	  Clients are just tradeable `IB::Accounts`.  
 
  * rename ' for_active_accounts' to `account_data`
		Account-data provides a thead-safe access to contrats, portfolio- and account-values auf a given account.

  * rename `simple_account_data_scan`  to `account_Data_scan`

  * connect: raises an error if connection is not possible because of using a not unique client_id

	* initialize::  tolerates arguments other then specified. 

	* made methods that never should call by users private:  
	  check_connection, initialize_alerts, initialize_managed_accounts, prepare_connection 
 
* lib/ib/gateway   
  
  Directory contains gateway related stuff

	* account-infos.rb
	* order-handling.rb

* lib/ib/alerts
   
	* included specific alert-definitions in this directory:
	  order-alerts, gateway-alerts

* moving model/spread.rb to `ib-api`  Gem

#### Preparation of a Gem-Release 

* Gateway#connect: initializing order-array by calling :RequestAllOrders after establishing the connection.

* Gateway#connect: Occasionally the request for AccountPositions/AllOrders fails. Then a reconnect is
                   appropriate. This is now implemented.

* Order.auto_adjust

     Auto Adjust implements a simple algotithm to ensure that an order is accepted
    
     It reads `contract_detail.min_tick`. 
    
     If min_tick < 0.01, the real tick-increments differ fron the min_tick_value
    
     For J36 (jardines) min tick is 0.001, but the minimal increment is 0.005
     For Tui1 its the samme, min_tick is 0.00001 , minimal increment ist 0.00005
    
     Thus, for min-tick smaller then 0.01, the value is rounded to the next higer digit.
     
     | min-tick     |  round     |
     |--------------|------------|
     |   10         |   110      |
     |    1         |   111      |
     |    0.1       |   111.1    |
     |    0.001     |   111.11   |
     |    0.0001    |   111.11   |
     |    0.00001   |   111.111  |
     |--------------|------------|

* Client.place:   defaults are 
  *   auto_adjust is "true" 
  *   convert_size: true

  If a negative value for 'total amount' is used, then Order.action is set to :sell.   
  If a positive value is used, Order.action is kept 

* Client.place raises an `IB::Symbol Error` if the order is not submitted 

