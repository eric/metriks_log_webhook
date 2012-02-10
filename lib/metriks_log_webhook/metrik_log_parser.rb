require 'active_support/core_ext/hash'

module MetriksLogWebhook
  class MetrikLogParser
    def initialize(prefix)
      @prefix = prefix
    end

    def parse(message)
      return unless data = message[/^#{Regexp.escape(@prefix)} (.*)$/, 1]

      h = HashWithIndifferentAccess.new
      data.split(' ').each do |entry|
        key, value = entry.split(':', 2)
        if value =~ /^(\d+)|(\d+\.\d+)$/
          value = value.to_f
        end
        h[key] = value
      end
      h
    end
  end
end
