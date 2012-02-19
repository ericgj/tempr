require File.expand_path('test_helper', File.dirname(__FILE__))

module RangeWithinOtherTests

  Fixtures = [ 
    {
      :case     => "inclusive ranges, other equals self",
      :subject  => (Date.civil(2012,2,13)..
                    Date.civil(2012,2,17)).extend(Tempr::DateTimeRange),
      :other    => Date.civil(2012,2,13)..Date.civil(2012,2,17),
      :expected_within  => true,
      :expected_subsume => true
    },
    {
      :case     => "inclusive ranges, other within self",
      :subject  => (Date.civil(2012,2,13)..
                    Date.civil(2012,2,17)).extend(Tempr::DateTimeRange),
      :other    => Date.civil(2012,2,13)..Date.civil(2012,2,16),
      :expected_within  => false,
      :expected_subsume => true
    },
    {
      :case     => "inclusive ranges, self within other",
      :subject  => (Date.civil(2012,2,13)..
                    Date.civil(2012,2,17)).extend(Tempr::DateTimeRange),
      :other    => Date.civil(2012,2,13)..Date.civil(2012,2,18),
      :expected_within  => true,
      :expected_subsume => false
    },    
    {
      :case     => "inclusive ranges, self intersects but not within other",
      :subject  => (Date.civil(2012,2,13)..
                    Date.civil(2012,2,17)).extend(Tempr::DateTimeRange),
      :other    =>  Date.civil(2012,2,14)..Date.civil(2012,2,18),
      :expected_within  => false,
      :expected_subsume => false
    },    
    {
      :case     => "inclusive ranges, self does not intersect other",
      :subject  => (Date.civil(2012,2,13)..
                    Date.civil(2012,2,17)).extend(Tempr::DateTimeRange),
      :other    =>  Date.civil(2012,2,18)..Date.civil(2012,2,19),
      :expected_within  => false,
      :expected_subsume => false
    },    
    {
      :case     => "exclusive ranges, same endpoint, both exclusive",
      :subject  => (Date.civil(2012,2,13)...
                    Date.civil(2012,2,17)).extend(Tempr::DateTimeRange),
      :other    =>  Date.civil(2012,2,13)...Date.civil(2012,2,17),
      :expected_within  => true,
      :expected_subsume => true
    },    
    {
      :case     => "exclusive ranges, same endpoint, other is non-exclusive, self is exclusive",
      :subject  => (Date.civil(2012,2,13)...
                    Date.civil(2012,2,17)).extend(Tempr::DateTimeRange),
      :other    =>  Date.civil(2012,2,13)..Date.civil(2012,2,17),
      :expected_within  => true,
      :expected_subsume => false
    },        
    {
      :case     => "exclusive ranges, same endpoint, other is exclusive, self is non-exclusive",
      :subject  => (Date.civil(2012,2,13)..
                    Date.civil(2012,2,17)).extend(Tempr::DateTimeRange),
      :other    =>  Date.civil(2012,2,13)...Date.civil(2012,2,17),
      :expected_within  => false,
      :expected_subsume => true
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