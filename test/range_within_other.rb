require File.expand_path('test_helper', File.dirname(__FILE__))

module RangeWithinOtherTests

  Fixtures = [ 
  # ------- date range cases
    {
      :case     => "inclusive date ranges, other equals self",
      :subject  => (Date.civil(2012,2,13)..
                    Date.civil(2012,2,17)).extend(Tempr::DateTimeRange),
      :other    => Date.civil(2012,2,13)..Date.civil(2012,2,17),
      :expected_within  => true,
      :expected_subsume => true
    },
    {
      :case     => "inclusive date ranges, other within self",
      :subject  => (Date.civil(2012,2,13)..
                    Date.civil(2012,2,17)).extend(Tempr::DateTimeRange),
      :other    => Date.civil(2012,2,13)..Date.civil(2012,2,16),
      :expected_within  => false,
      :expected_subsume => true
    },
    {
      :case     => "inclusive date ranges, self within other",
      :subject  => (Date.civil(2012,2,13)..
                    Date.civil(2012,2,17)).extend(Tempr::DateTimeRange),
      :other    => Date.civil(2012,2,13)..Date.civil(2012,2,18),
      :expected_within  => true,
      :expected_subsume => false
    },    
    {
      :case     => "inclusive date ranges, self intersects but not within other",
      :subject  => (Date.civil(2012,2,13)..
                    Date.civil(2012,2,17)).extend(Tempr::DateTimeRange),
      :other    =>  Date.civil(2012,2,14)..Date.civil(2012,2,18),
      :expected_within  => false,
      :expected_subsume => false
    },    
    {
      :case     => "inclusive date ranges, self does not intersect other",
      :subject  => (Date.civil(2012,2,13)..
                    Date.civil(2012,2,17)).extend(Tempr::DateTimeRange),
      :other    =>  Date.civil(2012,2,18)..Date.civil(2012,2,19),
      :expected_within  => false,
      :expected_subsume => false
    },    
    {
      :case     => "exclusive date ranges, same endpoint, both exclusive",
      :subject  => (Date.civil(2012,2,13)...
                    Date.civil(2012,2,17)).extend(Tempr::DateTimeRange),
      :other    =>  Date.civil(2012,2,13)...Date.civil(2012,2,17),
      :expected_within  => true,
      :expected_subsume => true
    },    
    {
      :case     => "exclusive date ranges, same endpoint, other is non-exclusive, self is exclusive",
      :subject  => (Date.civil(2012,2,13)...
                    Date.civil(2012,2,17)).extend(Tempr::DateTimeRange),
      :other    =>  Date.civil(2012,2,13)..Date.civil(2012,2,17),
      :expected_within  => true,
      :expected_subsume => false
    },        
    {
      :case     => "exclusive date ranges, same endpoint, other is exclusive, self is non-exclusive",
      :subject  => (Date.civil(2012,2,13)..
                    Date.civil(2012,2,17)).extend(Tempr::DateTimeRange),
      :other    =>  Date.civil(2012,2,13)...Date.civil(2012,2,17),
      :expected_within  => false,
      :expected_subsume => true
    },
    
  #---------- time range cases
        
    {
      :case     => "inclusive time ranges, other equals self",
      :subject  => (Time.new(2012,2,13,12,11,10)..
                    Time.new(2012,2,17,16,15,14)).extend(Tempr::DateTimeRange),
      :other    => (Time.new(2012,2,13,12,11,10)..
                    Time.new(2012,2,17,16,15,14)),
      :expected_within  => true,
      :expected_subsume => true
    },
    {
      :case     => "inclusive time ranges, other within self",
      :subject  => (Time.new(2012,2,13,12,11,10)..
                    Time.new(2012,2,17,16,15,14)).extend(Tempr::DateTimeRange),
      :other    => (Time.new(2012,2,13,12,11,10)..
                    Time.new(2012,2,17,16,15,13)),
      :expected_within  => false,
      :expected_subsume => true
    },
    {
      :case     => "inclusive time ranges, self within other",
      :subject  => (Time.new(2012,2,13,12,11,10)..
                    Time.new(2012,2,17,16,15,14)).extend(Tempr::DateTimeRange),
      :other    => (Time.new(2012,2,13,12,11,10)..
                    Time.new(2012,2,17,16,15,15)),
      :expected_within  => true,
      :expected_subsume => false
    },    
    {
      :case     => "inclusive time ranges, self intersects but not within other",
      :subject  => (Time.new(2012,2,13,12,11,10)..
                    Time.new(2012,2,17,16,15,14)).extend(Tempr::DateTimeRange),
      :other    => (Time.new(2012,2,13,12,11,11)..
                    Time.new(2012,2,17,16,15,15)),
      :expected_within  => false,
      :expected_subsume => false
    },    
    {
      :case     => "inclusive time ranges, self does not intersect other",
      :subject  => (Time.new(2012,2,13,12,11,10)..
                    Time.new(2012,2,17,16,15,14)).extend(Tempr::DateTimeRange),
      :other    => (Time.new(2012,2,17,16,15,15)..
                    Time.new(2012,2,17,16,16,0)),
      :expected_within  => false,
      :expected_subsume => false
    },
    
  #---------- date/time range cases

    {
      :case     => "date range compared to other time range, other equivalent to self",
      :subject  => (Date.civil(2012,2,13)..
                    Date.civil(2012,2,17)).extend(Tempr::DateTimeRange),
      :other    => (Time.new(2012,2,13,0,0,0)...
                    Time.new(2012,2,18,0,0,0)),
      :expected_within  => true,
      :expected_subsume => true
    },
    {
      :case     => "time range compared to other date range, self equivalent to other",
      :subject  => (Time.new(2012,2,13,0,0,0)...
                    Time.new(2012,2,18,0,0,0)).extend(Tempr::DateTimeRange),
      :other    => (Date.civil(2012,2,13)..
                    Date.civil(2012,2,17)),
      :expected_within  => true,
      :expected_subsume => true
    },
    {
      :case     => "date range compared to other time range, other within self",
      :subject  => (Date.civil(2012,2,13)..
                    Date.civil(2012,2,17)).extend(Tempr::DateTimeRange),
      :other    => (Time.new(2012,2,13,0,0,0)...
                    Time.new(2012,2,17,23,59,59)),
      :expected_within  => false,
      :expected_subsume => true
    },
    {
      :case     => "time range compared to other date range, other within self",
      :subject  => (Time.new(2012,2,13,0,0,0)...
                    Time.new(2012,2,18,0,0,0)).extend(Tempr::DateTimeRange),
      :other    => (Date.civil(2012,2,13)..
                    Date.civil(2012,2,16)),
      :expected_within  => false,
      :expected_subsume => true
    },
    {
      :case     => "date range compared to other time range, self within other",
      :subject  => (Date.civil(2012,2,13)..
                    Date.civil(2012,2,17)).extend(Tempr::DateTimeRange),
      :other    => (Time.new(2012,2,13,0,0,0)...
                    Time.new(2012,2,18,0,0,1)),
      :expected_within  => true,
      :expected_subsume => false
    },
    {
      :case     => "time range compared to other date range, self within other",
      :subject  => (Time.new(2012,2,13,0,0,0)...
                    Time.new(2012,2,18,0,0,0)).extend(Tempr::DateTimeRange),
      :other    => (Date.civil(2012,2,13)..
                    Date.civil(2012,2,18)),
      :expected_within  => true,
      :expected_subsume => false
    },
    {
      :case     => "date range compared to other time range, self intersects but not within other",
      :subject  => (Date.civil(2012,2,13)..
                    Date.civil(2012,2,17)).extend(Tempr::DateTimeRange),
      :other    => (Time.new(2012,2,14,0,0,0)...
                    Time.new(2012,2,18,0,0,1)),
      :expected_within  => false,
      :expected_subsume => false
    },    
    {
      :case     => "time range compared to other date range, self intersects but not within other",
      :subject  => (Time.new(2012,2,13,0,0,0)...
                    Time.new(2012,2,18,0,0,0)).extend(Tempr::DateTimeRange),
      :other    => (Date.civil(2012,2,14)..
                    Date.civil(2012,2,18)),
      :expected_within  => false,
      :expected_subsume => false
    },    
    {
      :case     => "date range compared to other time range, self does not intersect other",
      :subject  => (Date.civil(2012,2,13)..
                    Date.civil(2012,2,17)).extend(Tempr::DateTimeRange),
      :other    => (Time.new(2012,2,18,0,0,1)...
                    Time.new(2012,2,19,0,0,0)),
      :expected_within  => false,
      :expected_subsume => false
    },        
    {
      :case     => "time range compared to other date range, self does not intersect other",
      :subject  => (Time.new(2012,2,13,0,0,0)...
                    Time.new(2012,2,18,0,0,0)).extend(Tempr::DateTimeRange),
      :other    => (Date.civil(2012,2,19)..
                    Date.civil(2012,2,21)),
      :expected_within  => false,
      :expected_subsume => false
    }        
  ]
          
    
  describe "DateTimeRange#within and #subsume" do
 
    Fixtures.each do |fixture|
    
      describe fixture[:case] do
        let(:subject) {  fixture[:subject] }
        let(:other)   {  fixture[:other]   }
        
        it "within should return #{fixture[:expected_within]}" do
          assert_equal fixture[:expected_within], subject.within?(other)
        end
      
        it "subsume should return #{fixture[:expected_subsume]}" do
          assert_equal fixture[:expected_subsume], subject.subsume?(other)
        end        
      end
      
    end
    
  end

  
end