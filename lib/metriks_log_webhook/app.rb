module MetriksLogWebhook
  class App < Sinatra::Base
    set :root,     RACK_ROOT
    set :app_file, __FILE__

    set :metrik_prefix, ENV['METRIK_PREFIX'] || 'metriks:'
    set :metric_interval, 60

    set :memcached, Memcached.new(ENV['MEMCACHED'])
    set :metrics_client, LibratoMetrics.new(ENV['METRICS_EAMIL'], ENV['METRICS_TOKEN'])

    get '/' do
      'hello'
    end

    post '/submit' do
      payload = HashWithIndifferentAccess.new(Yajl::Parser.parse(params[:payload]))

      parser      = MetrikLogParser.new(metrik_prefix)
      metric_list = MetricList.new(metric_interval)

      payload[:events].each do |event|
        if data = parser.parse(event[:message])
          data[:source] ||= event[:hostname]
          metric_list.add(data)
        end
      end


    end
  end
end