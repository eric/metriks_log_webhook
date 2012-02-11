require 'test_helper'
require 'rack/test'

require 'metriks_log_webhook/app'

class AppTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    MetriksLogWebhook::App.tap do |app|
      app.set :cache, stub(:get => nil, :set => nil)

      app.metrics_client.connection.builder.tap do |c|
        c.swap 1, Faraday::Adapter::Test do |stub|
          stub.post '/v1/metrics' do
            [ 200, {}, '' ]
          end
        end
      end
    end
  end

  def test_get_root
    get '/'
  end

  def test_post
    payload = {
      :events => [
        {
          :message => "metriks: name=test type=timer time=#{Time.now.to_i} mean=0.928 one_minute_rate=837.3",
          :hostname => 'app1'
        },
        {
          :message => "metriks: name=test type=timer time=#{Time.now.to_i} mean=0.828 one_minute_rate=637.3",
          :hostname => 'app2'
        }
      ]
    }

    post '/submit', :payload => Yajl::Encoder.encode(payload)
  end
end