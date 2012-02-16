require File.expand_path('test_helper', File.dirname(__FILE__))

module TimeSubRangeTests
  module Fixtures
    
    # 20 seconds / minutes / hours
    BaseRanges = { :each_seconds => Time.parse('2012-02-13 15:32:41')...
                                    Time.parse('2012-02-13 15:33:01'),
                   :each_minutes => Time.parse('2012-02-13 13:46:25')...
                                    Time.parse('2012-02-13 14:06:25'),
                   :each_hours   => Time.parse('2012-02-13 12:52:22')...
                                    Time.parse('2012-02-14 08:52:22')
                 }
    
    ExclusiveDateRange    = Date.parse('2012-02-13')...Date.parse('2012-02-15')
    NonExclusiveDateRange = Date.parse('2012-02-13')..Date.parse('2012-02-14')
    
    # note: I don't particularly like generating fixtures like this,
    # but it's probably just as suceptible to error as hand-typing here
    module Expected
      
      Default = { 
        :each_seconds => 
          (0..19).inject([]) do |memo, i|
            s0 = BaseRanges[:each_seconds].begin
            memo << (s0+i...s0+i+1)
          end,
        :each_minutes => 
          (0..19).inject([]) do |memo, i|
            s0 = BaseRanges[:each_minutes].begin
            memo << (s0+i*60...s0+(i+1)*60)
          end,
        :each_hours   => 
          (0..19).inject([]) do |memo, i|
            s0 = BaseRanges[:each_hours].begin
            memo << (s0+i*60*60...s0+(i+1)*60*60)
          end      
      }
      
      Params3_0_1 = {
        :each_seconds => 
          (0..6).inject([]) do |memo, i|
            s0 = BaseRanges[:each_seconds].begin
            memo << (s0+(i*3)...s0+(i*3)+1)
          end,
        :each_minutes => 
          (0..6).inject([]) do |memo, i|
            s0 = BaseRanges[:each_minutes].begin
            memo << (s0+(i*3)*60...s0+(i*3+1)*60)
          end,
        :each_hours   => 
          (0..6).inject([]) do |memo, i|
            s0 = BaseRanges[:each_hours].begin
            memo << (s0+(i*3)*60*60...s0+(i*3+1)*60*60)
          end         
      }

      Params1_5_1 = {
        :each_seconds => 
          (0..14).inject([]) do |memo, i|
            s0 = BaseRanges[:each_seconds].begin+5
            memo << (s0+i...s0+i+1)
          end,
        :each_minutes => 
          (0..14).inject([]) do |memo, i|
            s0 = BaseRanges[:each_minutes].begin+5*60
            memo << (s0+i*60...s0+(i+1)*60)
          end,
        :each_hours   => 
          (0..14).inject([]) do |memo, i|
            s0 = BaseRanges[:each_hours].begin+5*60*60
            memo << (s0+i*60*60...s0+(i+1)*60*60)
          end      
      }
      
      Params3_0_3 = {
        :each_seconds => 
          (0..6).inject([]) do |memo, i|
            s0 = BaseRanges[:each_seconds].begin
            memo << (s0+(i*3)...s0+(i*3)+3)
          end,
        :each_minutes => 
          (0..6).inject([]) do |memo, i|
            s0 = BaseRanges[:each_minutes].begin
            memo << (s0+(i*3)*60...s0+(i*3+3)*60)
          end,
        :each_hours   => 
          (0..6).inject([]) do |memo, i|
            s0 = BaseRanges[:each_hours].begin
            memo << (s0+(i*3)*60*60...s0+(i*3+3)*60*60)
          end         
      }
      
      Params5_0_2 = {
        :each_seconds => 
          (0..3).inject([]) do |memo, i|
            s0 = BaseRanges[:each_seconds].begin
            memo << (s0+(i*5)...s0+(i*5)+2)
          end,
        :each_minutes => 
          (0..3).inject([]) do |memo, i|
            s0 = BaseRanges[:each_minutes].begin
            memo << (s0+(i*5)*60...s0+(i*5+2)*60)
          end,
        :each_hours   => 
          (0..3).inject([]) do |memo, i|
            s0 = BaseRanges[:each_hours].begin
            memo << (s0+(i*5)*60*60...s0+(i*5+2)*60*60)
          end         
      }

      Params1_0_3 = { 
        :each_seconds => 
          (0..19).inject([]) do |memo, i|
            s0 = BaseRanges[:each_seconds].begin
            memo << (s0+i...s0+i+3)
          end,
        :each_minutes => 
          (0..19).inject([]) do |memo, i|
            s0 = BaseRanges[:each_minutes].begin
            memo << (s0+i*60...s0+(i+3)*60)
          end,
        :each_hours   => 
          (0..19).inject([]) do |memo, i|
            s0 = BaseRanges[:each_hours].begin
            memo << (s0+i*60*60...s0+(i+3)*60*60)
          end      
      }
      
      Params7_1_3 = {
        :each_seconds => 
          (0..2).inject([]) do |memo, i|
            s0 = BaseRanges[:each_seconds].begin+1
            memo << (s0+(i*7)...s0+(i*7)+3)
          end,
        :each_minutes => 
          (0..2).inject([]) do |memo, i|
            s0 = BaseRanges[:each_minutes].begin+1*60
            memo << (s0+(i*7)*60...s0+(i*7+3)*60)
          end,
        :each_hours   => 
          (0..2).inject([]) do |memo, i|
            s0 = BaseRanges[:each_hours].begin+1*60*60
            memo << (s0+(i*7)*60*60...s0+(i*7+3)*60*60)
          end         
      }
      
    end
    
  end

  # ---

  describe 'DateTimeRange, single time iterators' do
    
    [:each_seconds, :each_minutes, :each_hours].each do |meth|
      describe meth do
        
        let(:subject) { Fixtures::BaseRanges[meth].extend(Tempr::DateTimeRange) }
        
        it 'must exhibit default behavior if no parameters passed' do
          results = subject.send(meth).to_a
          assert_equal Fixtures::Expected::Default[meth], results
        end
        
        it 'must iterate using passed step length' do
          results = subject.send(meth,3).to_a
          assert_equal Fixtures::Expected::Params3_0_1[meth], results
        end
        
        it 'must iterate starting at passed offset' do
          results = subject.send(meth,1,5).to_a
          assert_equal Fixtures::Expected::Params1_5_1[meth], results
        end
        
        it 'must return ranges of passed duration, duration == step' do
          results = subject.send(meth,3,0,3).to_a
          assert_equal Fixtures::Expected::Params3_0_3[meth], results
        end
        
        it 'must return ranges of passed duration, duration < step' do
          results = subject.send(meth,5,0,2).to_a
          assert_equal Fixtures::Expected::Params5_0_2[meth], results
        end
        
        it 'must return ranges of passed duration, duration > step' do
          results = subject.send(meth,1,0,3).to_a
          assert_equal Fixtures::Expected::Params1_0_3[meth], results
        end

        it 'must return ranges of passed step, offset, and duration' do
          results = subject.send(meth,7,1,3).to_a
          assert_equal Fixtures::Expected::Params7_1_3[meth], results
        end
        
      end
    
    end
    
    describe "with exclusive date ranges" do
      
      let(:subject) { Fixtures::ExclusiveDateRange.extend(Tempr::DateTimeRange) }
      
      it 'each_seconds must return ranges starting up to 23:59:59 of the end date' do
        last_result = subject.each_seconds.to_a.last
        assert_equal ( (Fixtures::ExclusiveDateRange.end.to_time - 1)...
                       Fixtures::ExclusiveDateRange.end.to_time ), 
                     last_result
      end

      it 'each_minutes must return ranges starting up to 23:59:00 of the end date' do
        last_result = subject.each_minutes.to_a.last
        assert_equal ( (Fixtures::ExclusiveDateRange.end.to_time - 60)...
                       Fixtures::ExclusiveDateRange.end.to_time ), 
                     last_result
      end

      it 'each_minutes must return ranges starting up to 23:00:00 of the end date' do
        last_result = subject.each_hours.to_a.last
        assert_equal ( (Fixtures::ExclusiveDateRange.end.to_time - 60*60)...
                       Fixtures::ExclusiveDateRange.end.to_time ), 
                     last_result
      end
      
    end

    describe "with non-exclusive date ranges" do
      
      let(:subject) { Fixtures::NonExclusiveDateRange.extend(Tempr::DateTimeRange) }
      
      it 'each_seconds must return ranges starting up to 23:59:59 of the end date + 1' do
        last_result = subject.each_seconds.to_a.last
        assert_equal ( ((Fixtures::NonExclusiveDateRange.end+1).to_time - 1)...
                       (Fixtures::NonExclusiveDateRange.end+1).to_time ), 
                     last_result
      end

      it 'each_minutes must return ranges starting up to 23:59:00 of the end date + 1' do
        last_result = subject.each_minutes.to_a.last
        assert_equal ( ((Fixtures::NonExclusiveDateRange.end+1).to_time - 60)...
                       (Fixtures::NonExclusiveDateRange.end+1).to_time ), 
                     last_result
      end

      it 'each_minutes must return ranges starting up to 23:00:00 of the end date + 1' do
        last_result = subject.each_hours.to_a.last
        assert_equal ( ((Fixtures::NonExclusiveDateRange.end+1).to_time - 60*60)...
                       (Fixtures::NonExclusiveDateRange.end+1).to_time ), 
                     last_result
      end
      
    end
      
    
  end

end   # namespace