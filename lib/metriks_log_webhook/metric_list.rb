module MetriksLogWebhook
  class MetricList
    def initialize(memcached, interval)
      @memcached = memcached
      @interval  = interval
      
      @gauges   = []
      @counters = []
    end

    def add(data)
      case data[:type]
      when 'counter'
        counter(data)
      when 'timer'
        timer(data)
      end
    end

    def timer(data)
      g = Gauge.new(data[:name], data[:time], :source => data[:source])
      g.add(data[:count], )

    end

    def counter(data)
      @counters << {
        :name   => data[:name],
        :time   => rounded_time(data[:time]),
        :value  => data[:count],
        :source => data[:source]
      }
    end

    def rounded_time(time)
      time = time.to_i
      time -= time % @interval
      time
    end
  end
end