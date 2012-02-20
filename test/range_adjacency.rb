require File.expand_path('test_helper', File.dirname(__FILE__))

module RangeAdjacencyTests

  Fixtures = [ 
    {
      :case     => "inclusive date ranges, other equals self",
      :subject  => (Date.civil(2012,2,13)..
                    Date.civil(2012,2,17)).extend(Tempr::DateTimeRange),
      :other    => Date.civil(2012,2,13)..Date.civil(2012,2,17),
      :precedes => false,
      :succeeds => false,
      :adjacent => false
    },
    {
      :case     => "inclusive date ranges, other within self",
      :subject  => (Date.civil(2012,2,13)..
                    Date.civil(2012,2,17)).extend(Tempr::DateTimeRange),
      :other    => Date.civil(2012,2,13)..Date.civil(2012,2,16),
      :precedes => false,
      :succeeds => false,
      :adjacent => false
    },
    {
      :case     => "inclusive date ranges, other precedes self",
      :subject  => (Date.civil(2012,2,13)..
                    Date.civil(2012,2,17)).extend(Tempr::DateTimeRange),
      :other    => Date.civil(2012,2,1)..Date.civil(2012,2,12),
      :precedes => false,
      :succeeds => true,
      :adjacent => true
    },
    {
      :case     => "inclusive date ranges, self precedes other",
      :subject  => (Date.civil(2012,2,13)..
                    Date.civil(2012,2,17)).extend(Tempr::DateTimeRange),
      :other    => Date.civil(2012,2,18)..Date.civil(2012,2,25),
      :precedes => true,
      :succeeds => false,
      :adjacent => true
    },
    {
      :case     => "exclusive date ranges, other equals self",
      :subject  => (Date.civil(2012,2,13)...
                    Date.civil(2012,2,18)).extend(Tempr::DateTimeRange),
      :other    => Date.civil(2012,2,13)...Date.civil(2012,2,18),
      :precedes => false,
      :succeeds => false,
      :adjacent => false
    },
    {
      :case     => "exclusive date ranges, other within self",
      :subject  => (Date.civil(2012,2,13)...
                    Date.civil(2012,2,18)).extend(Tempr::DateTimeRange),
      :other    => Date.civil(2012,2,13)...Date.civil(2012,2,17),
      :precedes => false,
      :succeeds => false,
      :adjacent => false
    },
    {
      :case     => "exclusive date ranges, other precedes self",
      :subject  => (Date.civil(2012,2,13)...
                    Date.civil(2012,2,18)).extend(Tempr::DateTimeRange),
      :other    => Date.civil(2012,2,1)...Date.civil(2012,2,13),
      :precedes => false,
      :succeeds => true,
      :adjacent => true
    },
    {
      :case     => "exclusive date ranges, self precedes other",
      :subject  => (Date.civil(2012,2,13)...
                    Date.civil(2012,2,18)).extend(Tempr::DateTimeRange),
      :other    => Date.civil(2012,2,18)...Date.civil(2012,2,25),
      :precedes => true,
      :succeeds => false,
      :adjacent => true
    },
    
  #---------- time range cases
        
    {
      :case     => "inclusive time ranges, other equals self",
      :subject  => (Time.new(2012,2,13,12,11,10)..
                    Time.new(2012,2,17,16,15,14)).extend(Tempr::DateTimeRange),
      :other    => (Time.new(2012,2,13,12,11,10)..
                    Time.new(2012,2,17,16,15,14)),
      :precedes => false,
      :succeeds => false,
      :adjacent => false
    },
    {
      :case     => "inclusive time ranges, other within self",
      :subject  => (Time.new(2012,2,13,12,11,10)..
                    Time.new(2012,2,17,16,15,14)).extend(Tempr::DateTimeRange),
      :other    => (Time.new(2012,2,13,12,11,10)..
                    Time.new(2012,2,17,16,15,13)),
      :precedes => false,
      :succeeds => false,
      :adjacent => false
    },
    {
      :case     => "inclusive time ranges, self precedes other",
      :subject  => (Time.new(2012,2,13,12,11,10)..
                    Time.new(2012,2,17,16,15,14)).extend(Tempr::DateTimeRange),
      :other    => (Time.new(2012,2,17,16,15,15)..
                    Time.new(2012,2,17,16,15,16)),
      :precedes => true,
      :succeeds => false,
      :adjacent => true
    },
    {
      :case     => "inclusive time ranges, other precedes self",
      :subject  => (Time.new(2012,2,13,0,0,0)..
                    Time.new(2012,2,17,0,0,0)).extend(Tempr::DateTimeRange),
      :other    => (Time.new(2012,2,1,0,0,0)..
                    Time.new(2012,2,12,23,59,59)),
      :precedes => false,
      :succeeds => true,
      :adjacent => true
    },
    {
      :case     => "exclusive time ranges, other equals self",
      :subject  => (Time.new(2012,2,13,12,11,10)...
                    Time.new(2012,2,17,16,15,14)).extend(Tempr::DateTimeRange),
      :other    => (Time.new(2012,2,13,12,11,10)...
                    Time.new(2012,2,17,16,15,14)),
      :precedes => false,
      :succeeds => false,
      :adjacent => false
    },
    {
      :case     => "inclusive time ranges, other within self",
      :subject  => (Time.new(2012,2,13,12,11,10)...
                    Time.new(2012,2,17,16,15,14)).extend(Tempr::DateTimeRange),
      :other    => (Time.new(2012,2,13,12,11,10)...
                    Time.new(2012,2,17,16,15,13)),
      :precedes => false,
      :succeeds => false,
      :adjacent => false
    },
    {
      :case     => "inclusive time ranges, self precedes other",
      :subject  => (Time.new(2012,2,13,12,11,10)...
                    Time.new(2012,2,17,16,15,14)).extend(Tempr::DateTimeRange),
      :other    => (Time.new(2012,2,17,16,15,14)..
                    Time.new(2012,2,17,16,15,16)),
      :precedes => true,
      :succeeds => false,
      :adjacent => true
    },
    {
      :case     => "inclusive time ranges, other precedes self",
      :subject  => (Time.new(2012,2,13,0,0,0)..
                    Time.new(2012,2,17,0,0,0)).extend(Tempr::DateTimeRange),
      :other    => (Time.new(2012,2,1,0,0,0)...
                    Time.new(2012,2,13,0,0,0)),
      :precedes => false,
      :succeeds => true,
      :adjacent => true
    },
  #---------- date/time range cases

    {
      :case     => "date range intersects other time range, other equivalent to self",
      :subject  => (Date.civil(2012,2,13)..
                    Date.civil(2012,2,17)).extend(Tempr::DateTimeRange),
      :other    => (Time.new(2012,2,13,0,0,0)...
                    Time.new(2012,2,18,0,0,0)),
      :precedes => false,
      :succeeds => false,
      :adjacent => false
    },
    {
      :case     => "time range compared to other date range, other within self",
      :subject  => (Time.new(2012,2,13,0,0,0)...
                    Time.new(2012,2,18,0,0,0)).extend(Tempr::DateTimeRange),
      :other    => (Date.civil(2012,2,13)..
                    Date.civil(2012,2,16)),
      :precedes => false,
      :succeeds => false,
      :adjacent => false
    },
    {
      :case     => "date range compared to other time range, self precedes other",
      :subject  => (Date.civil(2012,2,13)..
                    Date.civil(2012,2,17)).extend(Tempr::DateTimeRange),
      :other    => (Time.new(2012,2,18,0,0,0)...
                    Time.new(2012,2,19,0,0,0)),
      :precedes => true,
      :succeeds => false,
      :adjacent => true
    },
    {
      :case     => "time range compared to other date range, self precedes other",
      :subject  => (Time.new(2012,2,13,0,0,0)...
                    Time.new(2012,2,18,0,0,0)).extend(Tempr::DateTimeRange),
      :other    => (Date.civil(2012,2,18)..
                    Date.civil(2012,2,19)),
      :precedes => true,
      :succeeds => false,
      :adjacent => true
    },    
    {
      :case     => "date range compared to other time range, other precedes self",
      :subject  => (Date.civil(2012,2,13)..
                    Date.civil(2012,2,17)).extend(Tempr::DateTimeRange),
      :other    => (Time.new(2012,2,1,0,0,0)...
                    Time.new(2012,2,13,0,0,0)),
      :precedes => false,
      :succeeds => true,
      :adjacent => true
    },
    {
      :case     => "time range compared to other date range, other precedes self",
      :subject  => (Time.new(2012,2,13,0,0,0)...
                    Time.new(2012,2,18,0,0,0)).extend(Tempr::DateTimeRange),
      :other    => (Date.civil(2012,2,1)..
                    Date.civil(2012,2,12)),
      :precedes => false,
      :succeeds => true,
      :adjacent => true
    }
  ]
  
  describe "DateTimeRange#intersection_with, date ranges" do

    Fixtures.each do |fixture|
    
      describe fixture[:case] do
        let(:subject)  { fixture[:subject]  }
        let(:other)    { fixture[:other]    }
        let(:expected_precedes) { fixture[:precedes] }
        let(:expected_succeeds) { fixture[:succeeds] }
        let(:expected_adjacent) { fixture[:adjacent] }
        
        it 'should return expected precedes status' do
          actual = subject.precedes?(other)
          assert_equal expected_precedes, actual
        end
       
        it 'should return expected succeeds status' do
          actual = subject.succeeds?(other)
          assert_equal expected_succeeds, actual
        end
        
        it 'should return expected adjacent_to status' do
          actual = subject.adjacent_to?(other)
          assert_equal expected_adjacent, actual
        end

      end
    
    end
    
  end
  
end