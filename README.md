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

## Historical Data (EOD)
```
require 'ib-api'
require 'ib/eod'
```
Fetch historical data with just one line of code [wiki](https://github.com/ib-ruby/ib-ruby/wiki/Historical-Data)

## Order Prototypes
```
require 'ib-api'
require 'ib/order-prototypes'

order = IB::Limit.order size: 100, price: 10, action: :buy
order = IB::StopLimit.order size: 100, price: 10, stop_price: 9.5
```

then transmit the order through  the `place_order` method of IB::Connection (or IB::Gateway)

More details in the [wiki](https://github.com/ib-ruby/ib-ruby/wiki/Order-Prototypes)


## Spread Prototypes

```
require 'ib-api'
require 'ib/spread-prototypes'
```

Compose most common spreads through

```
s = IB::Straddle.build from: IB::Symbols::Index.stoxx, 
                            strike: 2400, 
                            expiry: 202103 
                            
s = IB::Strangle.build from: IB::Symbols::Index.stoxx, 
                            c: 2400, p: 2200, 
                            expiry: 202103 

```
and use the speads like any other contract. [wiki(https://github.com/ib-ruby/ib-ruby/wiki/Strangles,-Straddles-%26-Co)

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
