require File.expand_path('test_helper', File.dirname(__FILE__))

module RangeWithinOtherTests

  describe "DateTimeRange#within, non-exclusive date ranges" do
    
    describe "other equals self" do
      let(:subject) {  (Date.civil(2012,2,13)..
                        Date.civil(2012,2,17)).extend(Tempr::DateTimeRange)
                    }
      let(:other)   {   Date.civil(2012,2,13)..Date.civil(2012,2,17) }
      
      it "within should return true" do
        assert_equal true, subject.within?(other)
      end
   
      it "subsume should return true" do
        assert_equal true, subject.subsume?(other)
      end
      
    end
    
    describe "other within self" do
      let(:subject) {  (Date.civil(2012,2,13)..
                        Date.civil(2012,2,17)).extend(Tempr::DateTimeRange)
                    }
      let(:other)   {   Date.civil(2012,2,13)..Date.civil(2012,2,16) }
      
      it "within should return false" do
        assert_equal false, subject.within?(other)
      end
      
      it "subsume should return true" do
        assert_equal true, subject.subsume?(other)
      end
      
    end
    
    describe "self within other" do
      let(:subject) {  (Date.civil(2012,2,13)..
                        Date.civil(2012,2,17)).extend(Tempr::DateTimeRange)
                    }
      let(:other)   {   Date.civil(2012,2,13)..Date.civil(2012,2,18) }
      
      it "within should return true" do
        assert_equal true, subject.within?(other)
      end
    
      it "subsume should return false" do
        assert_equal false, subject.subsume?(other)
      end
      
    end
    
    describe "self intersects but not within other" do
      let(:subject) {  (Date.civil(2012,2,13)..
                        Date.civil(2012,2,17)).extend(Tempr::DateTimeRange)
                    }
      let(:other)   {   Date.civil(2012,2,14)..Date.civil(2012,2,18) }
      
      it "within should return false" do
        assert_equal false, subject.within?(other)
      end
    
      it "subsume should return false" do
        assert_equal false, subject.subsume?(other)
      end
      
    end
    
    describe "self does not intersect other" do
      let(:subject) {  (Date.civil(2012,2,13)..
                        Date.civil(2012,2,17)).extend(Tempr::DateTimeRange)
                    }
      let(:other)   {   Date.civil(2012,2,18)..Date.civil(2012,2,19) }
      
      it "within should return false" do
        assert_equal false, subject.within?(other)
      end
    
      it "subsume should return false" do
        assert_equal false, subject.subsume?(other)
      end
      
    end
    
  end
  
  describe "DateTimeRange#within, exclusive date ranges" do

    describe "same endpoint, both exclusive" do
      let(:subject) {  (Date.civil(2012,2,13)...
                        Date.civil(2012,2,17)).extend(Tempr::DateTimeRange)
                    }
      let(:other)   {   Date.civil(2012,2,13)...Date.civil(2012,2,17) }
      
      it "within should return true" do
        assert_equal true, subject.within?(other)
      end
   
      it "subsume should return true" do
        assert_equal true, subject.subsume?(other)
      end
      
    end
    
    describe "same endpoint, other is non-exclusive, self is exclusive" do
      let(:subject) {  (Date.civil(2012,2,13)...
                        Date.civil(2012,2,17)).extend(Tempr::DateTimeRange)
                    }
      let(:other)   {   Date.civil(2012,2,13)..Date.civil(2012,2,17) }
      
      it "within should return true" do
        assert_equal true, subject.within?(other)
      end
      
      it "subsume should return false" do
        assert_equal false, subject.subsume?(other)
      end
      
    end
    
    describe "same endpoint, other is exclusive, self is non-exclusive" do
      let(:subject) {  (Date.civil(2012,2,13)..
                        Date.civil(2012,2,17)).extend(Tempr::DateTimeRange)
                    }
      let(:other)   {   Date.civil(2012,2,13)...Date.civil(2012,2,17) }
      
      it "within should return false" do
        assert_equal false, subject.within?(other)
      end
    
      it "subsume should return true" do
        assert_equal true, subject.subsume?(other)
      end
      
    end
      
  end
  
end