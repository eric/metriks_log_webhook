require 'faraday'
require 'faraday_middleware'
require 'yajl/json_gem'

module MetriksLogWebhook
  class LibratoMetrics
    def self.connection
      @connection ||= Faraday::Connection.new('https://metrics-api.librato.com') do |b|
        b.use FaradayMiddleware::EncodeJson
        b.adapter Faraday.default_adapter
        b.use Faraday::Response::RaiseError
        b.use FaradayMiddleware::ParseJson, :content_type => /\bjson$/
      end.tap do |c|
        c.headers[:content_type] = 'application/json'
      end
    end

    def initialize(email, token)
      @email = email
      @token = token
    end

    def connection
      @connection ||= self.class.connection.dup.tap do |c|
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