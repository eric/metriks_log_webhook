require 'test_helper'

require 'metriks_log_webhook/metric_list'

class MetricListTest < Test::Unit::TestCase
  def setup
    memcached = stub(:set => nil, :get => nil)
    @list = MetriksLogWebhook::MetricList.new(memcached, 60)
  end

  def test_empty_to_hash
    assert_equal({ :gauges => [], :counters => [] }, @list.to_hash)
  end
  
  def test_counter
    data = {
      :name => 'test',
      :time => Time.now.to_i,
      :source => 'localhost',
      :count => 8273,
      :type => 'counter'
    }
    
    @list.add(data)
    
    assert_equal 8273, @list.to_hash[:counters][0][:value]
  end
  
  def test_meter
    data = {
      :name => 'test',
      :time => Time.now.to_i,
      :source => 'localhost',
      :mean => 827,
      :one_minute_rate => 822,
      :type => 'meter'
    }
    
    @list.add(data)
    
    assert_match /test\..*/, @list.to_hash[:gauges][0][:name]
    assert_equal 2, @list.to_hash[:gauges].length
  end
  
  def test_timer
    data = {
      :name => 'test',
      :time => Time.now.to_i,
      :source => 'localhost',
      :mean => 827,
      :one_minute_rate => 822,
      :type => 'timer'
    }
    
    @list.add(data)
    
    assert_match /test\..*/, @list.to_hash[:gauges][0][:name]
    assert_equal 2, @list.to_hash[:gauges].length
  end
  
  def test_utilization_timer
    data = {
      :name => 'test',
      :time => Time.now.to_i,
      :source => 'localhost',
      :mean => 827,
      :one_minute_rate => 822,
      :one_minute_utilization => 0.8,
      :type => 'utilization_timer'
    }
    
    @list.add(data)
    
    assert_match /test\..*/, @list.to_hash[:gauges][0][:name]
    assert_equal 3, @list.to_hash[:gauges].length
  end
end