# Bankscrap::Arquia

Bankscrap adapter for [Arquia Banca](https://www.arquia.es/) (only tested with personal accounts).


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'bankscrap-arquia'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bankscrap-arquia

## Usage

### From terminal
#### Bank account balance

    $ bankscrap balance Arquia --user YOUR_USER --password YOUR_PASSWORD --extra=nif:YOUR_NIF


#### Transactions

    $ bankscrap transactions Arquia --user YOUR_USER --password YOUR_PASSWORD --extra=nif:YOUR_NIF

---

For more details on usage instructions please read [Bankscrap readme](https://github.com/bankscrap/bankscrap/#usage).

### From Ruby code

**TODO**: check if your bank adapter needs more extra_args for the initializer.

```ruby
require 'bankscrap-arquia'
arquia = Bankscrap::Arquia::Bank.new(YOUR_USER, YOUR_PASSWORD, extra_args: {nif: YOUR_NIF})
```


## Contributing

1. Fork it ( https://github.com/bankscrap/bankscrap-arquia/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
