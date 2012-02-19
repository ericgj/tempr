require File.expand_path('test_helper', File.dirname(__FILE__))

module EachTimeOfDayTests
  module Fixtures

    BaseRanges = {:year  => Date.civil(2012,01,01)...
                            Date.civil(2013,01,01)
                 }
                
  end

  describe 'DateTimeRange#each_time_of_day' do

    describe "specified time zone" do
      let(:subject) { Fixtures::BaseRanges[:year].extend(Tempr::DateTimeRange) }
      let(:offset_string)  { '+09:00' }
      let(:offset) { 9*60*60 }
      
      it 'subranges should have the specified timezone offset' do
        subject.each_day.each_time_of_day("11:20pm",60*60,offset_string).each do |range|
          assert_equal offset, range.begin.utc_offset
          assert_equal offset, range.end.utc_offset
        end
      end
    end
            
    describe "across daylight savings time boundaries" do
      let(:subject) { Fixtures::BaseRanges[:year].extend(Tempr::DateTimeRange) }
      let(:time_string)      { "2:00pm" }
      let(:begin_hour_min)   { [14,0] }
      let(:end_hour_min)     { [15,0] }
      
      it 'should be at the same time of day regardless of time zone' do
        subject.each_day.each_time_of_day(time_string,60*60).each do |range|
          offset = range.begin.utc_offset
          actual_begin = range.begin.getlocal(offset)
          actual_end   = range.end.getlocal(offset)
          #puts "#{range.inspect}"
          assert_equal begin_hour_min, 
                       [actual_begin.hour, actual_begin.min], 
                       "for range: #{range}"
          assert_equal end_hour_min, 
                       [actual_end.hour, actual_end.min],   
                       "for range: #{range}"
        end
      end
      
    end
      
  end
  
  describe 'DateTimeRange#between_times' do
 
    let(:subject) { Fixtures::BaseRanges[:year].extend(Tempr::DateTimeRange) }
    
    def assert_range_matches( exp_begin, exp_end, range )
      offset = range.begin.utc_offset
      actual_begin = range.begin.getlocal(offset)
      actual_end   = range.end.getlocal(offset)       
      assert_equal exp_begin, 
                   [actual_begin.hour, actual_begin.min], 
                   "for range: #{range}"
      assert_equal exp_end, 
                   [actual_end.hour, actual_end.min],   
                   "for range: #{range}"                          
    end
    
    it 'should return correct ranges within a single day' do
      begin_hour_min = [16,45]
      end_hour_min   = [19,35]
      begin_string   = "#{begin_hour_min[0]}:#{begin_hour_min[1]}"
      end_string     = "#{end_hour_min[0]}:#{end_hour_min[1]}"
      
      subject.each_day.between_times(begin_string, end_string).each do |range|
        assert_range_matches begin_hour_min, end_hour_min, range
      end
    end
    
    it 'should return correct ranges across days' do
      begin_hour_min = [23,30]
      end_hour_min   = [02,17]
      begin_string   = "#{begin_hour_min[0]}:#{begin_hour_min[1]}"
      end_string     = "#{end_hour_min[0]}:#{end_hour_min[1]}"
      
      subject.each_day.between_times(begin_string, end_string).each do |range|
        assert_range_matches begin_hour_min, end_hour_min, range
        assert_equal 1, (range.end.to_date - range.begin.to_date), 
                     "for range: #{range}"
      end
    end
    
  end

end  # namespace