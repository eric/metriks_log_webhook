module MetriksLogWebhook
  class SumGauge
    def initialize(name, time, source, cache)
      @name   = name
      @time   = time.to_i
      @source = source
      @cache  = cache

      @data = {
        :value => 0
      }

      load
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

    def load
      if value = @cache.get(key)
        merge!(value)
      end
    end

    def save
      @cache.set(key, @data, 1000)
    end

    def to_hash
      @data.merge(:name => @name, :measure_time => @time, :source => @source)
    end
  end
end