require 'sinatra'
require 'yajl'
require 'active_support/core_ext/hash'

require 'metriks_log_webhook/librato_metrics'

module MetriksLogWebhook
  class App < Sinatra::Base
    configure do
      set :root, ENV['RACK_ROOT'] || RACK_ROOT
      set :app_file, __FILE__

      set :metrik_prefix, ENV['METRIK_PREFIX'] || 'metriks:'
      set :metric_interval, 60

      set :memcached, lambda { Memcached.new(ENV['MEMCACHED']) }
      set :metrics_client, LibratoMetrics.new(ENV['METRICS_EAMIL'], ENV['METRICS_TOKEN'])
    end

    get '/' do
      'hello'
    end

    post '/submit' do
      payload = HashWithIndifferentAccess.new(Yajl::Parser.parse(params[:payload]))

      parser      = MetrikLogParser.new(settings.metrik_prefix)
      metric_list = MetricList.new(settings.memcached, settings.metric_interval)

      payload[:events].each do |event|
        if data = parser.parse(event[:message])
          data[:source] ||= event[:hostname]
          metric_list.add(data)
        end
      end

      settings.metrics_client.submit(metric_list.to_hash)
    end
  end
end