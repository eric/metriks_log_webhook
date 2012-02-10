require 'faraday'
require 'faraday_middleware'

module MetriksLogWebhook
  class LibratoMetrics
    def initialize(options = {})
      @email = options[:email]
      @token = options[:token]
    end

    def connection
      @connection ||= Faraday::Connection.new('https://metrics-api.librato.com') do |b|
        b.use FaradayMiddleware::EncodeJson
        b.adapter Faraday.default_adapter
        b.use Faraday::Response::RaiseError
        b.use FaradayMiddleware::ParseJson, :content_type => /\bjson$/
      end.tap do |c|
        c.headers[:content_type] = 'application/json'
        c.basic_auth @email, @token
      end
    end

    def submit(body)
      connection.post '/v1/metrics' do |req|
        req.body = body
      end
    end
  end
end