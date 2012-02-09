require 'date'
require 'time'

module DateTimeSubrange

  def each_month(n=1,offset=0)
    build_subrange do |s|
      s.step    = n
      s.length  = 1
      s.adjust_range { |r| day_range(r) }
      s.offset       { |dt| dt.to_date >> offset }
      s.increment    { |dt,i| dt.to_date >> i }
    end
  end
      
  def each_wday(wd,n=1,offset=0)
    build_subrange do |s|
      s.step    = n
      s.length  = 0
      s.adjust_range  { |r| day_range(r) }
      s.offset        { |dt|   dt.to_date + (wd - dt.to_date.wday)%7 + offset*7 }
      s.increment     { |dt,i| dt.to_date + i*7 }
    end
  end
  
  def at_time(tm,dur=60*60)
    tm_p = Time.parse(tm)
    build_subrange do |s|
      s.step    = 60*60*24
      s.length  = dur
      s.adjust_range    { |r| time_range(r) }        
      s.offset          do |tm| 
                             Time.new( 
                               tm.year,   tm.month, tm.day,
                               tm_p.hour, tm_p.min, tm_p.sec, tm_p.utc_offset
                             )
                        end
      s.increment       { |tm,i| tm.to_time + i }
    end
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
  
  def build_subrange(&builder)
    SubRangeIterator.new(self, &builder)
  end
  
  class SubRangeIterator
    include Enumerable
    include DateTimeSubrange
    
    attr_accessor :range, :step, :length
    def step;   @step   ||= 1;         end
    def length; @length ||= self.step; end
    
    def range_extensions
      @range_extensions ||= 
        class << self.range
          self.included_modules - [Kernel]
        end
    end
    
    def initialize(range)
      self.range = range
      yield self if block_given?
    end
  
    def adjust_range(&p)
      self.range_proc = p
    end
    
    def offset(&p)
      self.offset_proc = p
    end
    
    def increment(&p)
      self.step_proc = p
    end
    
    def each(&b)
      if self.range.respond_to?(:each_by_step)
        self.range.each do |sub|
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
      rng = range_proc.call(rng)
#      puts "each_by_step range: #{rng}"
      initial = offset_proc.call(rng.begin)
      by_step(self.step).each do |n|
        next_begin = step_proc.call(initial,n)
        next_end   = step_proc.call(next_begin,self.length)
        if rng.respond_to?(:cover?) && 
           !rng.cover?(next_begin) 
          raise StopIteration
        end
        yield((next_begin...next_end).extend(*range_extensions))
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
  
    private
    
    attr_accessor :offset_proc, :step_proc, :range_proc
    def range_proc
      @range_proc ||= lambda {|r| r}
    end
    
  end
  
end


if $0 == __FILE__

  require 'pp'
  
  x = (Date.civil(2012,1,1)..Date.civil(2012,3,31)).extend(DateTimeSubrange)

  puts "Each Sunday at 11am UTC"
  pp x.each_month.each_wday(0).at_time('11:00 UTC').to_a
  puts
  
  puts "Every second Monday in every other month"
  pp x.each_month(2).each_wday(1,2,1).to_a
  puts
  
  
  
end
