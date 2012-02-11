module MetriksLogWebhook
  class AverageGauge
    def initialize(name, time, source, cache)
      @name   = name
      @time   = time.to_i
      @source = source
      @cache  = cache

      @data = {
        :count => 0,
        :sum => 0,
        :sum_of_squares => 0,
        :min => nil,
        :max => nil
      }

      load
    end

    def mark(value)
      @data[:count] += 1
      @data[:sum] += value
      @data[:sum_of_squares] += value ** 2

      if !@data[:min] || value < @data[:min]
        @data[:min] = value
      end

      if !@data[:max] || value > @data[:max]
        @data[:max] = value
      end
    end

    def merge!(other)
      other = other.symbolize_keys

      @data[:count] += other[:count]
      @data[:sum] += other[:sum]
      @data[:sum_of_squares]   += other[:sum_of_squares]

      if !@data[:min] || other[:min] < @data[:min]
        @data[:min] = other[:min]
      end

      if !@data[:max] || other[:max] > @data[:max]
        @data[:max] = other[:max]
      end
    end

    def key
      "average_gauge:#{@name}:#{@time}:#{@source}"
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