require 'date'
require 'time'

module DateTimeSubrange

  def each_month(n=1,offset=0)
    SubRangeIterator.new( self,
        n, 
        1,
        lambda {|dt| dt.to_date >> offset},
        lambda {|dt,i| dt.to_date >> i},
        lambda {|rng| day_range(rng) }
    )
  end
  
  def each_wday(wd,n=1)
    SubRangeIterator.new( self, 
        n, 
        0,
        lambda {|dt|   dt.to_date + (wd - dt.to_date.wday)%7 },
        lambda {|dt,i| dt.to_date + i*7},
        lambda {|rng| day_range(rng) }
    )  
  end
  
  def at_time(t,dur=60*60)
    tt = Time.parse(t)
    SubRangeIterator.new( self, 
        60*60*24, 
        dur,
        lambda {|tm|   Time.new( tm.year,tm.month,tm.day,
                                 tt.hour,tt.min,tt.sec,tt.utc_offset
                               )
               },
        lambda {|tm,i| tm.to_time + i},
        lambda {|rng| time_range(rng) }        
    )
  end
    
  def day_range(rng=self)
    if rng.respond_to?(:exclude_end?) && rng.exclude_end?
      Range.new(rng.begin.to_date, rng.end.to_date, true)
    else
      Range.new(rng.begin.to_date, rng.end.to_date + 1, true)
    end
  end
  
  def time_range(rng=self)
    if rng.begin.respond_to?(:sec) && rng.end.respond_to?(:sec)
      rng.dup
    else
      Range.new(rng.begin.to_time, (rng.end.to_date + 1).to_time, true)
    end
  end
  
  
  class SubRangeIterator
    include Enumerable
    include DateTimeSubrange
    
    attr_accessor :range, :step, :length, :initial_proc, :step_proc, :range_proc
    
    def initialize(range, step, length, initial_proc, step_proc, range_proc)
       self.range, self.step, self.length, self.initial_proc, self.step_proc, self.range_proc = \
            range,      step,      length,      initial_proc,      step_proc,      range_proc
    end
  
    def each(&b)
      if self.range.respond_to?(:each_by_step)
        self.range.each do |sub|
          each_by_step(sub, &b)
        end
      else
        each_by_step do |sub|
          puts "self.range = #{self.range} yielded: #{sub}"
          yield sub
        end
      end
    end
        
    def each_by_step(rng=self.range)
      rng = range_proc.call(rng)
      puts "each_by_step range: #{rng}"
      initial = initial_proc.call(rng.begin)
      by_step(self.step).each do |n|
        next_begin = step_proc.call(initial,n)
        next_end   = step_proc.call(next_begin,self.length)
        if rng.respond_to?(:cover?) && 
           !rng.cover?(next_begin) 
          raise StopIteration
        end
        yield((next_begin...next_end).extend(DateTimeSubrange))
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
  
  x = (Date.civil(2012,1,1)..Date.civil(2012,3,31)).extend(DateTimeSubrange)
  
  pp x.each_month.each_wday(0).to_a
  pp x.each_month.each_wday(0).at_time('11:00 UTC').to_a
end
