# HubspotEvent

HubspotEvent is based on [StripeEvent](https://github.com/integrallis/stripe_event) and uses the [ActiveSupport::Notifications API](https://api.rubyonrails.org/classes/ActiveSupport/Notifications.html) to process events. Subscribe to event types to process Hubspot events.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hubspot_event'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hubspot_event

## Usage

```ruby
# config/initializers/hubspot.rb
HubspotEvent.client_secret = ENV["HUBSPOT_CLIENT_SECRET"]

HubspotEvent.configure do |events|
  events.subscribe 'company.propertyChange' do |event|
    event["subscriptionType"]   #=> "company.propertyChange"
    event["portalId"]           #=> 123456
    event["objectId"]           #=> 182393
    event["propertyName"]       #=> "hubspot_owner_id"
    event["propertyValue"]      #=> 123
  end

  events.all do |event|
    # Handle all event types
  end
end
```

### Subscriber objects that respond to #call

```ruby
class HubspotCustomer
  def call(event)
    case event["subscriptionType"]
    when "customer.propertyChange"
      property_change(event)
    end
  end

  def property_change(event)
    # Handle property change event
  end
end
```

```ruby
HubspotEvent.configure do |events|
  events.subscribe 'customer', HubspotCustomer.new
end
```

## Webhook Signatures

Hubspot webhooks requests are signed with a [SHA-256 signature](https://developers.hubspot.com/docs/methods/webhooks/webhooks-overview#security), generated from the client secret and the payload body. The request signature is cryptographically verified before processing any of the events in the webhook. Any requests with an invalid signature will be rejected with a `404` response.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/huntresslabs/hubspot_event. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the HubspotEvent project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/huntresslabs/hubspot_event/blob/master/CODE_OF_CONDUCT.md).
