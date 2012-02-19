require File.expand_path('test_helper', File.dirname(__FILE__))

module RangeIntersectionTests

  Fixtures = [ 
    {
      :case     => "inclusive date ranges, other equals self",
      :subject  => (Date.civil(2012,2,13)..
                    Date.civil(2012,2,17)).extend(Tempr::DateTimeRange),
      :other    => Date.civil(2012,2,13)..Date.civil(2012,2,17),
      :expected => Date.civil(2012,2,13)...Date.civil(2012,2,18)
    },
    {
      :case     => "inclusive date ranges, other within self",
      :subject  => (Date.civil(2012,2,13)..
                    Date.civil(2012,2,17)).extend(Tempr::DateTimeRange),
      :other    => Date.civil(2012,2,13)..Date.civil(2012,2,16),
      :expected => Date.civil(2012,2,13)...Date.civil(2012,2,17)
    },
    {
      :case     => "inclusive date ranges, self within other",
      :subject  => (Date.civil(2012,2,13)..
                    Date.civil(2012,2,17)).extend(Tempr::DateTimeRange),
      :other    => Date.civil(2012,2,13)..Date.civil(2012,2,18),
      :expected => Date.civil(2012,2,13)...Date.civil(2012,2,18)
    },    
    {
      :case     => "inclusive date ranges, self intersects but not within other",
      :subject  => (Date.civil(2012,2,13)..
                    Date.civil(2012,2,17)).extend(Tempr::DateTimeRange),
      :other    => Date.civil(2012,2,14)..Date.civil(2012,2,18),
      :expected => Date.civil(2012,2,14)...Date.civil(2012,2,18)
    },  
    {
      :case     => "inclusive date ranges, self adjacent to other",
      :subject  => (Date.civil(2012,2,13)..
                    Date.civil(2012,2,17)).extend(Tempr::DateTimeRange),
      :other    => Date.civil(2012,2,18)..Date.civil(2012,2,19),
      :expected => Date.civil(2012,2,18)...Date.civil(2012,2,18)
    },
    {
      :case     => "inclusive date ranges, self does not intersect other",
      :subject  => (Date.civil(2012,2,13)..
                    Date.civil(2012,2,17)).extend(Tempr::DateTimeRange),
      :other    => Date.civil(2012,2,19)..Date.civil(2012,2,21),
      :expected => nil
    },
    {
      :case     => "exclusive date ranges, same endpoint, both exclusive",
      :subject  => (Date.civil(2012,2,13)...
                    Date.civil(2012,2,17)).extend(Tempr::DateTimeRange),
      :other    => Date.civil(2012,2,13)...Date.civil(2012,2,17),
      :expected => Date.civil(2012,2,13)...Date.civil(2012,2,17),
      :exclusive => true
    },
    {
      :case     => "exclusive date ranges, same endpoint, other is non-exclusive, self is exclusive",
      :subject  => (Date.civil(2012,2,13)...
                    Date.civil(2012,2,17)).extend(Tempr::DateTimeRange),
      :other    => Date.civil(2012,2,13)..Date.civil(2012,2,17),
      :expected => Date.civil(2012,2,13)...Date.civil(2012,2,17),
      :exclusive => true
    },
    {
      :case     => "exclusive date ranges, same endpoint, other is exclusive, self is non-exclusive",
      :subject  => (Date.civil(2012,2,13)..
                    Date.civil(2012,2,17)).extend(Tempr::DateTimeRange),
      :other    => Date.civil(2012,2,13)...Date.civil(2012,2,17),
      :expected => Date.civil(2012,2,13)...Date.civil(2012,2,17),
      :exclusive => true
    },     
    {
      :case     => "exclusive date ranges, different endpoint, both exclusive",
      :subject  => (Date.civil(2012,2,13)...
                    Date.civil(2012,2,17)).extend(Tempr::DateTimeRange),
      :other    => Date.civil(2012,2,14)...Date.civil(2012,2,18),
      :expected => Date.civil(2012,2,14)...Date.civil(2012,2,17),
      :exclusive => true
    },
    {
      :case     => "exclusive date ranges, different endpoint, other is non-exclusive, self is exclusive",
      :subject  => (Date.civil(2012,2,13)...
                    Date.civil(2012,2,17)).extend(Tempr::DateTimeRange),
      :other    => Date.civil(2012,2,12)..Date.civil(2012,2,16),
      :expected => Date.civil(2012,2,13)...Date.civil(2012,2,17),
      :exclusive => true
    },
    {
      :case     => "exclusive date ranges, different endpoint, other is exclusive, self is non-exclusive",
      :subject  => (Date.civil(2012,2,13)..
                    Date.civil(2012,2,17)).extend(Tempr::DateTimeRange),
      :other    => Date.civil(2012,2,11)...Date.civil(2012,2,15),
      :expected => Date.civil(2012,2,13)...Date.civil(2012,2,15),
      :exclusive => true
    },
    
  #---------- time range cases
        
    {
      :case     => "inclusive time ranges, other equals self",
      :subject  => (Time.new(2012,2,13,12,11,10)..
                    Time.new(2012,2,17,16,15,14)).extend(Tempr::DateTimeRange),
      :other    => (Time.new(2012,2,13,12,11,10)..
                    Time.new(2012,2,17,16,15,14)),
      :expected => (Time.new(2012,2,13,12,11,10)..
                    Time.new(2012,2,17,16,15,14))
    },
    {
      :case     => "inclusive time ranges, other within self",
      :subject  => (Time.new(2012,2,13,12,11,10)..
                    Time.new(2012,2,17,16,15,14)).extend(Tempr::DateTimeRange),
      :other    => (Time.new(2012,2,13,12,11,10)..
                    Time.new(2012,2,17,16,15,13)),
      :expected => (Time.new(2012,2,13,12,11,10)..
                    Time.new(2012,2,17,16,15,13))
    },
    {
      :case     => "inclusive time ranges, self within other",
      :subject  => (Time.new(2012,2,13,12,11,10)..
                    Time.new(2012,2,17,16,15,14)).extend(Tempr::DateTimeRange),
      :other    => (Time.new(2012,2,13,12,11,10)..
                    Time.new(2012,2,17,16,15,15)),
      :expected => (Time.new(2012,2,13,12,11,10)..
                    Time.new(2012,2,17,16,15,14))
    },    
    {
      :case     => "inclusive time ranges, self intersects but not within other",
      :subject  => (Time.new(2012,2,13,12,11,10)..
                    Time.new(2012,2,17,16,15,14)).extend(Tempr::DateTimeRange),
      :other    => (Time.new(2012,2,13,12,11,11)..
                    Time.new(2012,2,17,16,15,15)),
      :expected => (Time.new(2012,2,13,12,11,11)..
                    Time.new(2012,2,17,16,15,14))
    },    
    {
      :case     => "inclusive time ranges, self adjacent to other",
      :subject  => (Time.new(2012,2,13,12,11,10)..
                    Time.new(2012,2,17,16,15,14)).extend(Tempr::DateTimeRange),
      :other    => (Time.new(2012,2,17,16,15,15)..
                    Time.new(2012,2,17,16,15,16)),
      :expected => nil
    },
    {
      :case     => "inclusive time ranges, self does not intersect other",
      :subject  => (Time.new(2012,2,13,12,11,10)..
                    Time.new(2012,2,17,16,15,14)).extend(Tempr::DateTimeRange),
      :other    => (Time.new(2012,2,17,16,15,15)..
                    Time.new(2012,2,17,16,16,0)),
      :expected => nil
    },
    {
      :case     => "exclusive time ranges, same endpoint, both exclusive",
      :subject  => (Time.new(2012,2,13,12,11,10)...
                    Time.new(2012,2,17,16,15,14)).extend(Tempr::DateTimeRange),
      :other    => (Time.new(2012,2,13,12,11,10)...
                    Time.new(2012,2,17,16,15,14)),
      :expected => (Time.new(2012,2,13,12,11,10)...
                    Time.new(2012,2,17,16,15,14)),
      :exclusive => true
    },    
    {
      :case     => "exclusive time ranges, same endpoint, other is non-exclusive, self is exclusive",
      :subject  => (Time.new(2012,2,13,12,11,10)...
                    Time.new(2012,2,17,16,15,14)).extend(Tempr::DateTimeRange),
      :other    => (Time.new(2012,2,13,12,11,10)..
                    Time.new(2012,2,17,16,15,14)),
      :expected => (Time.new(2012,2,13,12,11,10)...
                    Time.new(2012,2,17,16,15,14)),
      :exclusive => true
    },        
    {
      :case     => "exclusive time ranges, same endpoint, other is exclusive, self is non-exclusive",
      :subject  => (Time.new(2012,2,13,12,11,10)..
                    Time.new(2012,2,17,16,15,14)).extend(Tempr::DateTimeRange),
      :other    => (Time.new(2012,2,13,12,11,10)...
                    Time.new(2012,2,17,16,15,14)),
      :expected => (Time.new(2012,2,13,12,11,10)...
                    Time.new(2012,2,17,16,15,14)),
      :exclusive => true
    },
    
  #---------- date/time range cases

    {
      :case     => "date range intersects other time range, other equivalent to self",
      :subject  => (Date.civil(2012,2,13)..
                    Date.civil(2012,2,17)).extend(Tempr::DateTimeRange),
      :other    => (Time.new(2012,2,13,0,0,0)...
                    Time.new(2012,2,18,0,0,0)),
      :expected => (Time.new(2012,2,13,0,0,0)...
                    Time.new(2012,2,18,0,0,0))
    },
    {
      :case     => "time range compared to other date range, self equivalent to other",
      :subject  => (Time.new(2012,2,13,0,0,0)...
                    Time.new(2012,2,18,0,0,0)).extend(Tempr::DateTimeRange),
      :other    => (Date.civil(2012,2,13)..
                    Date.civil(2012,2,17)),
      :expected => (Time.new(2012,2,13,0,0,0)...
                    Time.new(2012,2,18,0,0,0))
    },
    {
      :case     => "date range compared to other time range, other within self",
      :subject  => (Date.civil(2012,2,13)..
                    Date.civil(2012,2,17)).extend(Tempr::DateTimeRange),
      :other    => (Time.new(2012,2,13,0,0,0)...
                    Time.new(2012,2,17,23,59,59)),
      :expected => (Time.new(2012,2,13,0,0,0)...
                    Time.new(2012,2,17,23,59,59))
    },
    {
      :case     => "time range compared to other date range, other within self",
      :subject  => (Time.new(2012,2,13,0,0,0)...
                    Time.new(2012,2,18,0,0,0)).extend(Tempr::DateTimeRange),
      :other    => (Date.civil(2012,2,13)..
                    Date.civil(2012,2,16)),
      :expected => (Time.new(2012,2,13,0,0,0)...
                    Time.new(2012,2,17,0,0,0))
    },
    {
      :case     => "date range compared to other time range, self within other",
      :subject  => (Date.civil(2012,2,13)..
                    Date.civil(2012,2,17)).extend(Tempr::DateTimeRange),
      :other    => (Time.new(2012,2,13,0,0,0)...
                    Time.new(2012,2,18,0,0,1)),
      :expected => (Time.new(2012,2,13,0,0,0)...
                    Time.new(2012,2,18,0,0,0))
    },
    {
      :case     => "time range compared to other date range, self within other",
      :subject  => (Time.new(2012,2,13,0,0,0)...
                    Time.new(2012,2,18,0,0,0)).extend(Tempr::DateTimeRange),
      :other    => (Date.civil(2012,2,13)..
                    Date.civil(2012,2,18)),
      :expected => (Time.new(2012,2,13,0,0,0)...
                    Time.new(2012,2,18,0,0,0))
    },
    {
      :case     => "date range compared to other time range, self intersects but not within other",
      :subject  => (Date.civil(2012,2,13)..
                    Date.civil(2012,2,17)).extend(Tempr::DateTimeRange),
      :other    => (Time.new(2012,2,14,0,0,0)...
                    Time.new(2012,2,18,0,0,1)),
      :expected => (Time.new(2012,2,14,0,0,0)...
                    Time.new(2012,2,18,0,0,0))
    },    
    {
      :case     => "time range compared to other date range, self intersects but not within other",
      :subject  => (Time.new(2012,2,13,0,0,0)...
                    Time.new(2012,2,18,0,0,0)).extend(Tempr::DateTimeRange),
      :other    => (Date.civil(2012,2,14)..
                    Date.civil(2012,2,18)),
      :expected => (Time.new(2012,2,14,0,0,0)...
                    Time.new(2012,2,18,0,0,0))
    },    
    {
      :case     => "date range compared to other time range, self adjacent to other",
      :subject  => (Date.civil(2012,2,13)..
                    Date.civil(2012,2,17)).extend(Tempr::DateTimeRange),
      :other    => (Time.new(2012,2,18,0,0,0)...
                    Time.new(2012,2,19,0,0,0)),
      :expected => (Time.new(2012,2,18,0,0,0)...
                    Time.new(2012,2,18,0,0,0))
    },
    {
      :case     => "time range compared to other date range, self adjacent to other",
      :subject  => (Time.new(2012,2,13,0,0,0)...
                    Time.new(2012,2,18,0,0,0)).extend(Tempr::DateTimeRange),
      :other    => (Date.civil(2012,2,18)..
                    Date.civil(2012,2,19)),
      :expected => (Time.new(2012,2,18,0,0,0)...
                    Time.new(2012,2,18,0,0,0))
    },
    {
      :case     => "date range compared to other time range, self does not intersect other",
      :subject  => (Date.civil(2012,2,13)..
                    Date.civil(2012,2,17)).extend(Tempr::DateTimeRange),
      :other    => (Time.new(2012,2,18,0,0,1)...
                    Time.new(2012,2,19,0,0,0)),
      :expected => nil
    },        
    {
      :case     => "time range compared to other date range, self does not intersect other",
      :subject  => (Time.new(2012,2,13,0,0,0)...
                    Time.new(2012,2,18,0,0,0)).extend(Tempr::DateTimeRange),
      :other    => (Date.civil(2012,2,19)..
                    Date.civil(2012,2,21)),
      :expected => nil
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
            assert_equal expected, actual
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
