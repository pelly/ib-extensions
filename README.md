# IB/Extensions

Helpers and Macros that ease the usage of the TWS-API of Interactive Brokers

to activate use
```
gem 'ib-extensions',  git: 'https://github.com/ib-ruby/ib-extensions.git'
```
in the Gemfile and require the extensions as needed


## Verify
```
require 'ib-api'
require 'ib/verify'
```
Verifies a given contract, for details refer to the [wiki]( https://github.com/ib-ruby/ib-ruby/wiki/Contracts%3A-Create,-Verify-and-Store)

## Market Price
```
require 'ib-api'
require 'ib/market-price'
```
Returns the most recent market-price of a given contract  [wiki](https://github.com/ib-ruby/ib-ruby/wiki/Case-Study%3A-Get-Market-Price)

## End of Day Data
```
require 'ib-api'
require 'ib/eod'
```
Fetch historical data with just one line of code [wiki](https://github.com/ib-ruby/ib-ruby/wiki/Historical-Data)

## Gateway 
```
require 'ib-gateway'
```
IB::Gateway is an alternative to IB::Connection. Upon initialization, it detects active accounts and stores them in a thread safe array. 
Details in the [wiki](https://github.com/ib-ruby/ib-ruby/wiki/Gateway).

Its used in [Simple Monitor](https://github.com/ib-ruby/simple-monitor)





## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/ib-extensions. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/ib-extensions/blob/master/CODE_OF_CONDUCT.md).


## Code of Conduct

Everyone interacting in the Ib::Extensions project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/ib-extensions/blob/master/CODE_OF_CONDUCT.md).
