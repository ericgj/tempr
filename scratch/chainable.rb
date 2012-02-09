# first a simpler case: 
# subranges of integers

module Subrange

  def each_nth(n,len=1,offset=0)
    SubRangeIterator.new( self, n, len,
                          lambda {|dt| dt + offset},
                          lambda {|dt,i| dt + i}
                        )
  end  
  
  class SubRangeIterator
    include Enumerable
    include Subrange
    
    attr_accessor :range, :step, :length, :initial_proc, :step_proc

    def begin; self.range.begin; end
    def end; self.range.end; end
    
    def initialize(range, step, length, initial_proc, step_proc)
       self.range, self.step, self.length, self.initial_proc, self.step_proc = \
            range,      step,      length,      initial_proc,      step_proc
    end
  
    def each(&b)
      if SubRangeIterator === self.range
        self.range.each do |sub|
#          puts "sub.range = #{sub}"
          each_by_step(sub, &b)
        end
      else
        each_by_step do |sub|
#          puts "self.range = #{self.range} yielded: #{sub}"
          yield sub
        end
      end
    end
        
    def each_by_step(rng=self.range)
      initial = initial_proc.call(rng.begin)
      by_step(self.step).each do |n|
        next_begin = step_proc.call(initial,n)
        next_end   = step_proc.call(next_begin,self.length)
        if rng.respond_to?(:end) && 
           rng.end && 
           next_end > rng.end
          raise StopIteration
        end
        yield((next_begin...next_end).extend(Subrange))
      end
    end
    
    # step enumerator
    def by_step(n)
      @step_enumerator ||= Enumerator.new do |y|
        i=0
        loop do
          y << i; i+=n
        end
      end
    end
    
  end
  
end

if $0 == __FILE__

  require 'pp'
  
  x = (0..100).extend(Subrange)
  y = (2..3).extend(Subrange)
  
  pp  x.each_nth(14,1,2).to_a

  pp  y.each_nth(0.4,0.2).to_a
  
  pp  x.each_nth(14,1,2).each_nth(0.4,0.2).to_a
  
  pp  x.each_nth(20,20).each_nth(4,4).each_nth(3,1).to_a
  
end



__END__

# "every other month on third thursday at 2pm EST"
# range.each_month(2).on_thursdays(2).at_time('2:00pm EST')


def each_month(n,offset=0)
  TimeRangeEnumerator.new( self, n,
               Proc.new {|dt| dt.to_date >> offset},
               Proc.new {|dt, i| dt.to_date >> i}
             )
end

def on_wday(wd,n)
  TimeRangeEnumerator.new( self, n,
               Proc.new {|dt| (wd - dt.wday)%7 },
               Proc.new {|dt, i| dt.to_date + i*7}
             )
end

def at_time(t)
end



def each
  each_subrange do |subrange|
    yield subrange
  end
end
    
def each_subrange(&b)
  if range.respond_to?(:each_subrange)
    range.each_subrange do |subrange|
      
    end 
  else
    # get range
    
  end
end




  
  # generic time/date iteration using step enumerator below
  def each_by_step(n,step_proc,initial_proc=nil)
    initial_proc ||= lambda {|dt| dt}
    initial = initial_proc.call(self.begin)
    by_step(n).each do |step|
      next_val = step_proc.call(offset_init,step)
      if self.respond_to?(:end) && self.end && next_val > self.end
        raise StopIteration
      end
      yield(next_val)
    end
  end
  
  # step enumerator
  def by_step(n)
    Enumerator.new do |y|
      i=0
      loop do
        y << i; i+=n
      end
    end
  end
