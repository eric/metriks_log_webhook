module MetriksLogWebhook
  class Gauge
    def initialize(name, time, options = {})
      @name   = name
      @time   = time.to_i
      @source = options[:source]

      @data = {
        :count => 0,
        :sum => 0,
        :min => nil,
        :max => nil
      }
    end

    def add(count, sum, min, max)
      @data[:count] += count
      @data[:sum]   += sum

      if !@data[:min] || min < @data[:min]
        @data[:min] = min
      end

      if !@data[:max] || max > @data[:max]
        @data[:max] = max
      end
    end

    def merge!(other)
      other = other.symbolize_keys

      add(other[:count], other[:sum], other[:min], other[:max])
    end

    def key
      "gauge:#{@name}:#{@time}:#{@source}"
    end

    def load(memcached)
      if value = memcached.get(key)
        merge!(Yajl::Parser.parse(value))
      end
    end

    def save(memcached)
      memcached.set(key, Yajl::Encoder.encode(@data))
    end

    def to_hash
      @data.merge(:name => @name, :measure_time => @time, :source => @source)
    end
  end
end