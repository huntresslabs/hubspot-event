module HubspotEvent
  class WebhookController < ActionController::Base
    if Rails.application.config.action_controller.default_protect_from_forgery
      skip_before_action :verify_authenticity_token
    end

    before_action :verify_webhook

    rescue_from SignatureVerificationError, with: :bad_request

    def event
      webhook_params.sort_by { |e| e["occurredAt"] }.each do |event|
        # Convert the strong parameters to a hash. This is OK because we're already
        # verified the payload came from Hubspot and each event type has a unique
        # set of parameters
        HubspotEvent.instrument(event.to_unsafe_h)
      end

      head :ok
    end

    private

    def verify_webhook
      secret = HubspotEvent.client_secret
      payload = request.body.read
      signature = request.headers["X-Hubspot-Signature"]
      computed = Digest::SHA256.hexdigest(secret + payload)

      raise SignatureVerificationError unless signature == computed
    end

    def bad_request
      head :bad_request
    end

    def webhook_params
      params.require("_json")
    end
  end
end