require 'faraday'
require 'faraday_middleware'
require 'yajl/json_gem'

module MetriksLogWebhook
  class LibratoMetrics
    LIMIT_PER_POST = 1000

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
      puts "Submitting #{body[:gauges].length} gauges to librato"

      while body[:gauges].length > LIMIT_PER_POST
        post(:gauges => body[:gauges].shift(LIMIT_PER_POST))
      end

      while body[:counters].length > LIMIT_PER_POST
        post(:counters => body[:counters].shift(LIMIT_PER_POST))
      end

      post(body)
    end

    def post(body)
      connection.post '/v1/metrics' do |req|
        req.body = body
      end
    rescue Faraday::Error::ClientError => ex
      puts "Librato Metrics error response: #{ex.message}"
      puts "Headers: #{ex.response[:headers].inspect}"
      puts "Body: #{ex.response[:body]}"
      raise
    end
  end
end