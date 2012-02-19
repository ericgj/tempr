require File.expand_path('test_helper', File.dirname(__FILE__))

module RangeIntersectionTests

  Fixtures = [ 
    {
      :case     => "inclusive ranges, other equals self",
      :subject  => (Date.civil(2012,2,13)..
                    Date.civil(2012,2,17)).extend(Tempr::DateTimeRange),
      :other    => Date.civil(2012,2,13)..Date.civil(2012,2,17),
      :expected => Date.civil(2012,2,13)..Date.civil(2012,2,17)
    },
    {
      :case     => "inclusive ranges, other within self",
      :subject  => (Date.civil(2012,2,13)..
                    Date.civil(2012,2,17)).extend(Tempr::DateTimeRange),
      :other    => Date.civil(2012,2,13)..Date.civil(2012,2,16),
      :expected => Date.civil(2012,2,13)..Date.civil(2012,2,16)
    },
    {
      :case     => "inclusive ranges, self within other",
      :subject  => (Date.civil(2012,2,13)..
                    Date.civil(2012,2,17)).extend(Tempr::DateTimeRange),
      :other    => Date.civil(2012,2,13)..Date.civil(2012,2,18),
      :expected => Date.civil(2012,2,13)..Date.civil(2012,2,17)
    },    
    {
      :case     => "inclusive ranges, self intersects but not within other",
      :subject  => (Date.civil(2012,2,13)..
                    Date.civil(2012,2,17)).extend(Tempr::DateTimeRange),
      :other    => Date.civil(2012,2,14)..Date.civil(2012,2,18),
      :expected => Date.civil(2012,2,14)..Date.civil(2012,2,17)
    },  
    {
      :case     => "inclusive ranges, self does not intersect other",
      :subject  => (Date.civil(2012,2,13)..
                    Date.civil(2012,2,17)).extend(Tempr::DateTimeRange),
      :other    => Date.civil(2012,2,18)..Date.civil(2012,2,19),
      :expected => nil
    },
    {
      :case     => "exclusive ranges, same endpoint, both exclusive",
      :subject  => (Date.civil(2012,2,13)...
                    Date.civil(2012,2,17)).extend(Tempr::DateTimeRange),
      :other    => Date.civil(2012,2,13)...Date.civil(2012,2,17),
      :expected => Date.civil(2012,2,13)...Date.civil(2012,2,17),
      :exclusive => true
    },
    {
      :case     => "exclusive ranges, same endpoint, other is non-exclusive, self is exclusive",
      :subject  => (Date.civil(2012,2,13)...
                    Date.civil(2012,2,17)).extend(Tempr::DateTimeRange),
      :other    => Date.civil(2012,2,13)..Date.civil(2012,2,17),
      :expected => Date.civil(2012,2,13)...Date.civil(2012,2,17),
      :exclusive => true
    },
    {
      :case     => "exclusive ranges, same endpoint, other is exclusive, self is non-exclusive",
      :subject  => (Date.civil(2012,2,13)..
                    Date.civil(2012,2,17)).extend(Tempr::DateTimeRange),
      :other    => Date.civil(2012,2,13)...Date.civil(2012,2,17),
      :expected => Date.civil(2012,2,13)...Date.civil(2012,2,17),
      :exclusive => true
    },     
    {
      :case     => "exclusive ranges, different endpoint, both exclusive",
      :subject  => (Date.civil(2012,2,13)...
                    Date.civil(2012,2,17)).extend(Tempr::DateTimeRange),
      :other    => Date.civil(2012,2,14)...Date.civil(2012,2,18),
      :expected => Date.civil(2012,2,14)...Date.civil(2012,2,17),
      :exclusive => true
    },
    {
      :case     => "exclusive ranges, different endpoint, other is non-exclusive, self is exclusive",
      :subject  => (Date.civil(2012,2,13)...
                    Date.civil(2012,2,17)).extend(Tempr::DateTimeRange),
      :other    => Date.civil(2012,2,12)..Date.civil(2012,2,16),
      :expected => Date.civil(2012,2,13)..Date.civil(2012,2,16),
      :exclusive => true
    },
    {
      :case     => "exclusive ranges, different endpoint, other is exclusive, self is non-exclusive",
      :subject  => (Date.civil(2012,2,13)..
                    Date.civil(2012,2,17)).extend(Tempr::DateTimeRange),
      :other    => Date.civil(2012,2,11)...Date.civil(2012,2,15),
      :expected => Date.civil(2012,2,13)...Date.civil(2012,2,15),
      :exclusive => true
    }     
  ]


      
  describe "DateTimeRange#intersection_with, date ranges" do

    Fixtures.each do |fixture|
    
      describe fixture[:case] do
        let(:subject)  { fixture[:subject]  }
        let(:other)    { fixture[:other]    }
        let(:expected) { fixture[:expected] }
        
        it 'should return expected range' do
          actual = subject.intersection_with(other)
          if expected.nil?
            assert_nil actual
          else
            assert_equal expected.begin, actual.begin
            assert_equal expected.end,   actual.end
          end
        end
       
        if fixture[:exclusive]
          it 'should return expected exclusivity' do
            actual = subject.intersection_with(other)
            assert_equal expected.exclude_end?, actual.exclude_end?
          end
        end
        
      end
    
    end
    
  end

end
