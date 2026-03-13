require "paypal-checkout-sdk"
require "net/http"
require "json"

module PayPalClient
  def self.environment
    if Rails.env.production?
      PayPal::LiveEnvironment.new(
        ENV["PAYPAL_CLIENT_ID"],
        ENV["PAYPAL_CLIENT_SECRET"]
      )
    else
      PayPal::SandboxEnvironment.new(
        ENV["PAYPAL_CLIENT_ID"],
        ENV["PAYPAL_CLIENT_SECRET"]
      )
    end
  end

  def self.client
    PayPal::PayPalHttpClient.new(environment)
  end

  def self.base_url
    Rails.env.production? ?
      "https://api.paypal.com" :
      "https://api.sandbox.paypal.com"
  end

  def self.access_token
    uri = URI("#{base_url}/v1/oauth2/token")
    req = Net::HTTP::Post.new(uri)
    req.basic_auth(ENV["PAYPAL_CLIENT_ID"], ENV["PAYPAL_CLIENT_SECRET"])
    req.set_form_data(grant_type: "client_credentials")
    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |h| h.request(req) }
    JSON.parse(res.body)["access_token"]
  end
end
