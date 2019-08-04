# Bankscrap::Arquia

[Bankscrap](https://github.com/bankscrap/bankscrap) adapter for [Arquia Banca](https://www.arquia.es/) (only tested with personal accounts).

Contact: open an issue or email us at bankscrap@protonmail.com.

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

    $ bankscrap balance Arquia --credentials=user:YOUR_USER nif:YOUR_DNI password:YOUR_PASSWORD


#### Transactions

    $ bankscrap transactions Arquia --credentials=user:YOUR_USER nif:YOUR_DNI password:YOUR_PASSWORD

---

For more details on usage instructions please read [Bankscrap readme](https://github.com/bankscrap/bankscrap/#usage).

### From Ruby code

```ruby
require 'bankscrap-arquia'
arquia = Bankscrap::Arquia::Bank.new(user: YOUR_USER, nif: YOUR_NIF, password: YOUR_PASSWORD)
```


## Contributing

1. Fork it ( https://github.com/bankscrap/bankscrap-arquia/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
