require File.expand_path('test_helper', File.dirname(__FILE__))

module Fixtures

  BaseRanges = {:local => Time.parse('2012-01-01 00:00:00 -0500')...
                          Time.parse('2013-01-01 00:00:00 -0500'),
                :utc   => Time.parse('2012-01-01 00:00:00 UTC')...
                          Time.parse('2013-01-01 00:00:00 UTC')
               }
              
end

describe 'DateTimeRange#at_time' do

  [:local, :utc].each do |time_type|
  
    describe "across daylight savings time boundaries for #{time_type} times" do
    
      let(:subject) { Fixtures::BaseRanges[time_type].extend(Tempr::DateTimeRange) }
      
      it 'should be at the same time of day regardless of time zone' do
        subject.each_day.at_time("2:00pm",60*60).each do |range|
          offset = range.begin.utc_offset
          actual = range.begin.getlocal(offset).hour
          #puts "#{range}"
          assert_equal 14, actual, "for range: #{range}"
        end
      end
      
    end
    
  end
end
