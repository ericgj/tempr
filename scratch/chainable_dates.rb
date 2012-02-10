require 'date'
require 'time'

module DateTimeSubrange
      
  Sunday    = Date::DAYNAMES.index("Sunday")
  Monday    = Date::DAYNAMES.index("Monday")
  Tuesday   = Date::DAYNAMES.index("Tuesday")
  Wednesday = Date::DAYNAMES.index("Wednesday")
  Thursday  = Date::DAYNAMES.index("Thursday")
  Friday    = Date::DAYNAMES.index("Friday")
  Saturday  = Date::DAYNAMES.index("Saturday")
  Sun = Sunday
  Mon = Monday
  Tue = Tuesday
  Wed = Wednesday
  Thu = Thursday
  Fri = Friday
  Sat = Saturday

  January   = Date::MONTHNAMES.index("January")
  February  = Date::MONTHNAMES.index("February")
  March     = Date::MONTHNAMES.index("March")
  April     = Date::MONTHNAMES.index("April")
  May       = Date::MONTHNAMES.index("May")
  June      = Date::MONTHNAMES.index("June")
  July      = Date::MONTHNAMES.index("July")
  August    = Date::MONTHNAMES.index("August")
  September = Date::MONTHNAMES.index("September")
  October   = Date::MONTHNAMES.index("October")
  November  = Date::MONTHNAMES.index("November")
  December  = Date::MONTHNAMES.index("December")
  Jan = January
  Feb = February
  Mar = March
  Apr = April
  Jun = June
  Jul = July
  Aug = August
  Sep = September
  Oct = October
  Nov = November
  Dec = December
  
  def each_seconds(n=1, offset=0, dur=1)
    build_subrange do |s|
      s.step    = n
      s.adjust_range { |r| time_range(r) }
      s.offset       { |tm|   tm.to_time + offset }
      s.increment    { |tm,i| tm.to_time + i }
      s.span         { |tm| tm.to_time + dur }
    end
  end
  alias each_second each_seconds
  
  def each_minutes(n=1, offset=0, dur=1)
    each_seconds(n*60, offset*60, dur*60)
  end
  alias each_minute each_minutes
  
  def each_hours(n=1, offset=0, dur=1)
    each_seconds(n*60*60, offset*60*60, dur*60*60)
  end
  alias each_hour each_hours
  
  def each_days(n=1,offset=0,dur=1)
    build_subrange do |s|
      s.step    = n
      s.adjust_range  { |r| day_range(r) }
      s.offset        { |dt|   dt.to_date + offset }
      s.increment     { |dt,i| dt.to_date + i }
      s.span          { |dt| dt.to_date + dur }
    end
  end
  alias each_day each_days
  
  def each_weeks(n=1, offset=0)
    each_days(n*7, offset*7)
  end
  alias each_week each_weeks
  
  def each_wdays(wd,n=1,offset=0)
    build_subrange do |s|
      s.step    = n
      s.adjust_range  { |r| day_range(r) }
      s.offset        { |dt|   dt.to_date + (wd - dt.to_date.wday)%7 + offset*7 }
      s.increment     { |dt,i| dt.to_date + i*7 }
      s.span          { |dt| dt.to_date + 0 }
    end
  end
  alias each_wday each_wdays
    
  def each_sunday(   n=1, offset=0); each_wdays(Sun,n,offset); end
  def each_monday(   n=1, offset=0); each_wdays(Mon,n,offset); end
  def each_tuesday(  n=1, offset=0); each_wdays(Tue,n,offset); end
  def each_wednesday(n=1, offset=0); each_wdays(Wed,n,offset); end
  def each_thursday( n=1, offset=0); each_wdays(Thu,n,offset); end
  def each_friday(   n=1, offset=0); each_wdays(Fri,n,offset); end
  def each_saturday( n=1, offset=0); each_wdays(Sat,n,offset); end
  
  def each_months(n=1,offset=0,dur=1)
    build_subrange do |s|
      s.step    = n
      s.adjust_range { |r| day_range(r) }
      s.offset       { |dt|   dt.to_date >> offset }
      s.increment    { |dt,i| dt.to_date >> i }
      s.span         { |dt| dt.to_date >> dur }
    end
  end
  alias each_month each_months
  
  def each_monthnum(nmonth,n=1)
    build_subrange do |s|
      s.step   = n
      s.adjust_range { |r| day_range(r) }
      s.offset       { |dt| dt >> (nmonth - dt.month)%12 }
      s.increment    { |dt,i| dt.to_date >> i*12 }      
      s.span         { |dt| dt.to_date >> 1 }
    end
  end
  
  def each_years(n=1,offset=0,dur=1)
    build_subrange do |s|
      s.step    = n
      s.adjust_range { |r| day_range(r) }
      s.offset       { |dt|   Date.civil(dt.year + offset, dt.month, dt.day) }
      s.increment    { |dt,i| Date.civil(dt.year + i,      dt.month, dt.day) }
      s.span         { |dt|   Date.civil(dt.year + dur, dt.month, dt.day) }
    end 
  end
  alias each_year each_years
  
  
  # day of each month
  def on_day(nday,dur=0)
    build_subrange do |s|
      s.step   = 1
      s.adjust_range   { |r| day_range(r) }
      s.offset         do |dt| 
                            totdays = ((Date.civil(dt.year,dt.month,1) >> 1)-1).day
                            dt.to_date + (nday - dt.day)%totdays
                       end
      s.increment      { |dt,i| dt.to_date >> i }
      s.span           { |dt| dt.to_date + dur  }
    end
  end
  
  # time of each day
  def at_time(tm,dur=0)
    tm_p = Time.parse(tm)
    build_subrange do |s|
      s.step    = 60*60*24
      s.adjust_range    { |r| time_range(r) }        
      s.offset          do |tm| 
                             Time.new( 
                               tm.year,   tm.month, tm.day,
                               tm_p.hour, tm_p.min, tm_p.sec, tm_p.utc_offset
                             )
                        end
      s.increment       { |tm,i| tm.to_time + i }
      s.span            { |tm| tm.to_time + dur }
    end
  end
    
  # convert to date range
  # and make exclusive if not already
  def day_range(rng=self)
    if rng.respond_to?(:exclude_end?) && rng.exclude_end?
      Range.new(rng.begin.to_date, rng.end.to_date, true)
    else
      Range.new(rng.begin.to_date, rng.end.to_date + 1, true)
    end
  end
  
  # unless already a time range,
  # convert to times and make exclusive
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
    
    def span(&p)
      self.span_proc = p
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
        next_end   = span_proc.call(next_begin)
        if rng.respond_to?(:cover?) && !rng.cover?(next_begin) 
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
    
    attr_accessor :offset_proc, :step_proc, :span_proc, :range_proc
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
  
  puts "Each 15th of the month"
  pp x.each_month.on_day(15).to_a
  puts

  puts "Each February"
  pp x.each_monthnum(2).to_a
  
end
