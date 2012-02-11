require 'sinatra'
require 'yajl'
require 'active_support/core_ext/hash'
require 'dalli'

require 'metriks_log_webhook/librato_metrics'
require 'metriks_log_webhook/metrik_log_parser'
require 'metriks_log_webhook/metric_list'

module MetriksLogWebhook
  class App < Sinatra::Base
    configure do
      set :root, ENV['RACK_ROOT'] || RACK_ROOT
      set :app_file, __FILE__

      set :metrik_prefix, ENV['METRIK_PREFIX'] || 'metriks:'
      set :metric_interval, 60

      set :cache, lambda { Dalli::Client.new }
      set :metrics_client, LibratoMetrics.new(ENV['METRICS_EMAIL'], ENV['METRICS_TOKEN'])
    end

    get '/' do
      'hello'
    end

    post '/submit' do
      payload = HashWithIndifferentAccess.new(Yajl::Parser.parse(params[:payload]))

      parser      = MetrikLogParser.new(settings.metrik_prefix)
      metric_list = MetricList.new(settings.cache, settings.metric_interval)

      payload[:events].each do |event|
        if data = parser.parse(event[:message])
          data[:source] ||= event[:hostname]
          metric_list.add(data)
        end
      end

      metric_list.save

      body = metric_list.to_hash

      settings.metrics_client.submit(body)
    end
  end
end