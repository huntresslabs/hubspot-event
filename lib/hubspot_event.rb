require "hubspot-ruby"

require "hubspot_event/version"
require "hubspot_event/engine" if defined?(Rails)

module HubspotEvent
  class Error < StandardError; end
  class SignatureVerificationError < Error; end

  class << self
    attr_accessor :adapter, :backend, :namespace, :event_filter
    attr_accessor :client_secret

    def configure(&block)
      raise ArgumentError, "must provide a block" unless block_given?
      yield self
    end

    def instrument(event)
      event = event_filter.call(event)
      backend.instrument(namespace.call(event["subscriptionType"]), event) if event
    end

    def subscribe(name, callable = Proc.new)
      backend.subscribe(namespace.to_regexp(name), adapter.call(callable))
    end

    def all(callable = Proc.new)
      subscribe nil, callable
    end
  end

  class Namespace < Struct.new(:value, :delimiter)
    def call(name = nil)
      "#{value}#{delimiter}#{name}"
    end

    def to_regexp(name = nil)
      %r{^#{Regexp.escape call(name)}}
    end
  end

  class NotificationAdapter < Struct.new(:subscriber)
    def self.call(callable)
      new(callable)
    end

    def call(*args)
      payload = args.last
      subscriber.call(payload)
    end
  end

  self.adapter = NotificationAdapter
  self.backend = ActiveSupport::Notifications
  self.namespace = Namespace.new("hubspot_event", ".")
  self.event_filter = lambda { |event| event }
end
