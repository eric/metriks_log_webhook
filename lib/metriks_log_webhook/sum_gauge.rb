module MetriksLogWebhook
  class SumGauge
    def initialize(name, time, options = {})
      @name   = name
      @time   = time.to_i
      @source = options[:source]

      @data = {
        :value => 0
      }
    end
    
    def mark(value)
      @data[:value] += value
    end

    def merge!(other)
      other = other.symbolize_keys
      
      @data[:value] += other[:value]
    end

    def key
      "sum_gauge:#{@name}:#{@time}:#{@source}"
    end

    def load(memcached)
      if value = memcached.get(key)
        merge!(value)
      end
    end

    def save(memcached)
      memcached.set(key, @data)
    end

    def to_hash
      @data.merge(:name => @name, :measure_time => @time, :source => @source)
    end
  end
end