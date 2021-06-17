# IB/Extensions

---

__Documentation: [https://ib-ruby.github.io/ib-doc/](https://ib-ruby.github.io/ib-doc/)__  

__Questions, Contributions, Remarks: [Discussions are opened in ib-api](https://github.com/ib-ruby/ib-api/discussions)__

---

__Helpers and Macros that ease the usage of the TWS-API of Interactive Brokers__

To activate use
```
gem 'ib-extensions'
```
in the Gemfile and require the extensions as needed

## Include all
(except gateway)
```
require 'ib-api'
require 'ib/extensions'
```

## Verify
```
require 'ib-api'
require 'ib/verify'
```
Verifies a given contract, for details refer to the [documentation](https://ib-ruby.github.io/ib-doc/Verify_contracts.html )

## Market Price
```
require 'ib-api'
require 'ib/market-price'
```
Returns the most recent market-price of a given contract  ( [documentation](https://ib-ruby.github.io/ib-doc/market_price.html) )

## Historical Data (EOD)
```
require 'ib-api'
require 'ib/eod'

puts IB::Symbols.Index.estx.eod( duration: '10 d' )
```
Fetch historical data with just one line of code  ([documentation](https://ib-ruby.github.io/ib-doc/Historical_data.html) )

## Order Prototypes
```
require 'ib-api'
require 'ib/order-prototypes'

order = IB::Limit.order size: 100, price: 10, action: :buy
order = IB::StopLimit.order size: 100, price: 10, stop_price: 9.5
```

then transmit the order through  the [place_order](https://ib-ruby.github.io/ib-doc/order_placement.html)  method of IB::Connection or  Account-based  preview, place, modify and cancel methods of [IB::Gateway](https://ib-ruby.github.io/ib-doc/order_placement.html).

More details in the [documentation](https://ib-ruby.github.io/ib-doc/order_prototypes.html) 


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
and use the speads like any other contract. ([documentation](https://ib-ruby.github.io/ib-doc/spreads.html))

## Gateway 
```
require 'ib-gateway'
```
IB::Gateway is an alternative to IB::Connection. Upon initialization, it detects active accounts and stores them in a thread safe array. 
Details in the [documentation](https://ib-ruby.github.io/ib-doc/gateway.html)

Its used in [Simple Monitor](https://github.com/ib-ruby/simple-monitor)


## Notebooks
**`IB-Ruby`** code can be executed in [iruby jupyter notebooks](https://github.com/SciRuby/iruby). A few scripts are included in [IB-Examples](https://github.com/ib-ruby/ib-examples). (*.ipynb- files)


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ib-ruby/ib-extensions. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[ib-ruby/ib-extensions/blob/master/CODE_OF_CONDUCT.md).


## Code of Conduct

Everyone interacting in the Ib::Extensions project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/ib-ruby/ib-extensions/blob/master/CODE_OF_CONDUCT.md).
