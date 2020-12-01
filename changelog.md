
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
