require 'test_helper'

require 'metriks_log_webhook/metrik_log_parser'

class MetrikLogParserTest < Test::Unit::TestCase
  def setup
    @prefix = "metriks: "
    @parser = MetriksLogWebhook::MetrikLogParser.new(@prefix)
  end

  def test_parser_no_match
    assert_nil @parser.parse('bogus')
  end

  def test_parser_match
    result = @parser.parse("#{@prefix} string=value int=5 float=7.2")

    assert_equal 'value', result['string']
    assert_equal 5, result['int']
    assert_equal 7.2, result['float']
  end
end