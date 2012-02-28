require 'metriks_log_webhook/sum_gauge'
require 'metriks_log_webhook/average_gauge'

module MetriksLogWebhook
  class MetricList
    def initialize(memcached, interval)
      @memcached = memcached
      @interval  = interval

      @gauges = {}
      @counters = []
    end

    def add(data)
      case data[:type]
      when 'counter'
        add_counter(data)
      when 'timer'
        add_timer(data)
      when 'utilization_timer'
        add_utilization_timer(data)
      when 'meter'
        add_meter(data)
      else
        raise "Unknown data type: #{data[:type].inspect}"
      end
    end

    def add_counter(data)
      counter(data[:name], data[:time], data[:source], data[:count])
    end

    def add_timer(data)
      average_gauge(data[:name] + '.mean', data[:time], data[:source], data[:mean])
      sum_gauge(data[:name] + '.one_minute_rate', data[:time], data[:source], data[:one_minute_rate])

      if data[:median]
        average_gauge(data[:name] + '.median', data[:time], data[:source], data[:median])
      end

      if data[:"95th_percentile"]
        average_gauge(data[:name] + '.95th_percentile', data[:time], data[:source], data[:"95th_percentile"])
      end
    end

    def add_utilization_timer(data)
      average_gauge(data[:name] + '.mean', data[:time], data[:source], data[:mean])
      sum_gauge(data[:name] + '.one_minute_rate', data[:time], data[:source], data[:one_minute_rate])
      average_gauge(data[:name] + '.one_minute_utilization', data[:time], data[:source], data[:one_minute_utilization])

      if data[:median]
        average_gauge(data[:name] + '.median', data[:time], data[:source], data[:median])
      end

      if data[:"95th_percentile"]
        average_gauge(data[:name] + '.95th_percentile', data[:time], data[:source], data[:"95th_percentile"])
      end
    end

    def add_meter(data)
      sum_gauge(data[:name], data[:time], data[:source], data[:one_minute_rate])
    end

    def save
      @gauges.each do |key, gauge|
        gauge.save
      end
    end

    def to_hash
      gauges = @gauges.collect do |name, gauge|
        gauge.to_hash
      end

      {
        :counters => @counters,
        :gauges => gauges
      }
    end

    protected
    def average_gauge(name, time, source, value)
      time = rounded_time(time)
      key = [ name, time, source ].join('/')
      @gauges[key] ||= AverageGauge.new(name, time, source, @memcached)
      @gauges[key].mark(value)
    end

    def sum_gauge(name, time, source, value)
      time = rounded_time(time)
      key = [ name, time, source ].join('/')
      @gauges[key] ||= SumGauge.new(name, time, source, @memcached)
      @gauges[key].mark(value)
    end

    def counter(name, time, source, value)
      time = rounded_time(time)

      @counters << {
        :name   => name,
        :time   => time,
        :source => source,
        :value  => value
      }
    end

    def rounded_time(time)
      time = time.to_i
      time -= time % @interval
      time
    end
  end
end