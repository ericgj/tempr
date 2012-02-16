require 'date'
require 'time'

module Tempr

  # Extensions for date or time ranges (or range-like objects)
  # To generate subranges from chainable rules
  #
  # For example, 
  #
  # To generate a recurring hourly appointment at 2pm on the third Thursdays of each month in 2012:
  #
  #     range = (Date.civil(2012,1,1)...Date.civil(2013,1,1)).extend(Tempr::DateTimeRange)
  #     subrange = range.each_month.thursday(2).at_time('2:00pm',60*60)
  #
  # This gives you an enumerable you can iterate over:
  #
  #     pp subrange.to_a
  #     #=>  [ 2012-01-19 14:00:00 -0500...2012-01-19 15:00:00 -0500,
  #            2012-02-16 14:00:00 -0500...2012-02-16 15:00:00 -0500,
  #            2012-03-15 14:00:00 -0400...2012-03-15 15:00:00 -0400,
  #            2012-04-19 14:00:00 -0400...2012-04-19 15:00:00 -0400,
  #            2012-05-17 14:00:00 -0400...2012-05-17 15:00:00 -0400,
  #            2012-06-21 14:00:00 -0400...2012-06-21 15:00:00 -0400,
  #            2012-07-19 14:00:00 -0400...2012-07-19 15:00:00 -0400,
  #            2012-08-16 14:00:00 -0400...2012-08-16 15:00:00 -0400,
  #            2012-09-20 14:00:00 -0400...2012-09-20 15:00:00 -0400,
  #            2012-10-18 14:00:00 -0400...2012-10-18 15:00:00 -0400,
  #            2012-11-15 14:00:00 -0500...2012-11-15 15:00:00 -0500,
  #            2012-12-20 14:00:00 -0500...2012-12-20 15:00:00 -0500  ]
  #
  # Or check for inclusion of a date/time:
  #
  #     subrange.any? {|r| r.cover?(Time.parse("2012-05-17 2:30pm")) }
  #
  # Note that the order of the chained rules is important, they must be defined
  # from the widest to the narrowest date/time range.
  #
  # During iteration, each rule is applied on the array of ranges defined by the
  # previous rule.
  #
  # The methods are roughly divided into methods for generating recurring subranges (e.g., "each_month"),
  # and methods for finding a single subrange, by offset (e.g., "wednesday(1)" for the second wednesday)
  #
  # In both cases, an enumerable is returned so that you can continue to chain rules together.
  #   
  module DateTimeRange

    # day of week shortcuts - as methods so accessible to mixin target classes
    # Note probably should change this so it copies constants over in extend_object or something
    def Sunday    ; Date::DAYNAMES.index("Sunday");    end
    def Monday    ; Date::DAYNAMES.index("Monday");    end
    def Tuesday   ; Date::DAYNAMES.index("Tuesday");   end
    def Wednesday ; Date::DAYNAMES.index("Wednesday"); end
    def Thursday  ; Date::DAYNAMES.index("Thursday");  end
    def Friday    ; Date::DAYNAMES.index("Friday");    end
    def Saturday  ; Date::DAYNAMES.index("Saturday");  end
    def Sun ; self.Sunday;    end
    def Mon ; self.Monday;    end
    def Tue ; self.Tuesday;   end
    def Wed ; self.Wednesday; end
    def Thu ; self.Thursday;  end
    def Fri ; self.Friday;    end
    def Sat ; self.Saturday;  end

    def WEEKDAYS; [self.Mon, self.Tue, self.Wed, self.Thu, self.Fri]; end
    def WEEKENDS; [self.Sat, self.Sun]; end
    
    # month shortcuts - as methods so accessible to mixin target classes
    
    def January   ; Date::MONTHNAMES.index("January");   end
    def February  ; Date::MONTHNAMES.index("February");  end
    def March     ; Date::MONTHNAMES.index("March");     end
    def April     ; Date::MONTHNAMES.index("April");     end
    def May       ; Date::MONTHNAMES.index("May");       end
    def June      ; Date::MONTHNAMES.index("June");      end
    def July      ; Date::MONTHNAMES.index("July");      end
    def August    ; Date::MONTHNAMES.index("August");    end
    def September ; Date::MONTHNAMES.index("September"); end
    def October   ; Date::MONTHNAMES.index("October");   end
    def November  ; Date::MONTHNAMES.index("November");  end
    def December  ; Date::MONTHNAMES.index("December");  end
    def Jan ; self.January;   end
    def Feb ; self.February;  end
    def Mar ; self.March;     end
    def Apr ; self.April;     end
    def Jun ; self.June;      end
    def Jul ; self.July;      end
    def Aug ; self.August;    end
    def Sep ; self.September; end
    def Oct ; self.October;   end
    def Nov ; self.November;  end
    def Dec ; self.December;  end
    
    # ---
    
    # seconds iterator:
    #   "every +n+ seconds, starting at +offset+, grouped into +dur+ second intervals"
    #
    # if no parameters passed,
    #   "every second of range grouped into one-second intervals"
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
    
    def second(offset=0); each_seconds(1,offset).limit_to(1); end
    
    # minutes iterator:
    # "every +n+ minutes, starting at +offset+ minutes, +dur+ minute intervals"
    #
    # if no parameters passed,
    #   "every minute of range grouped into one-minute intervals"
    def each_minutes(n=1, offset=0, dur=1)
      each_seconds(n*60, offset*60, dur*60)
    end
    alias each_minute each_minutes
    
    def minute(offset=0); each_minutes(1,offset).limit_to(1); end
    
    # hours iterator:
    # "every +n+ hours, starting at +offset+ hours, +dur+ hour intervals"
    #
    # if no parameters passed,
    #   "every hour of range grouped into one-hour intervals"
    def each_hours(n=1, offset=0, dur=1)
      each_seconds(n*60*60, offset*60*60, dur*60*60)
    end
    alias each_hour each_hours
    
    def hour(offset=0); each_hours(1,offset).limit_to(1); end
    
    # days iterator:
    # "every +n+ days, starting at +offset+ days, +dur+ day intervals"
    #
    # if no parameters passed,
    #   "every day of range grouped into one-day intervals"
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
    
    def day(offset=0); each_day(1,offset).limit_to(1); end
    
    # weeks iterator:
    # "every +n+ weeks, starting at +offset+ weeks, +dur+ week intervals"
    #
    # if no parameters passed,
    #   "every week of range grouped into one-week intervals"
    def each_weeks(n=1, offset=0, dur=1)
      each_days(n*7, offset*7, dur*7)
    end
    alias each_week each_weeks
    
    def week(offset=0); each_weeks(1,offset).limit_to(1); end
    
    # single day-of-week iterator:
    # "every +n+th weekday +wd+, starting at +offset+ weeks, +dur+ day intervals"
    #
    # +wd+ is required. Typically, `each_sunday`, `each_monday` called instead.
    #
    # if no other parameters passed,
    #   "every weekday +wd+ of range grouped into one-day intervals"
    def each_wdays(wd,n=1,offset=0,dur=1)
      build_subrange do |s|
        s.step    = n
        s.adjust_range  { |r| day_range(r) }
        s.offset        { |dt|   dt.to_date + (wd - dt.to_date.wday)%7 + offset*7 }
        s.increment     { |dt,i| dt.to_date + i*7 }
        s.span          { |dt| dt.to_date + dur }
      end
    end
    alias each_wday each_wdays
              
    # "every +n+th Sunday, starting at +offset+ weeks, +dur+ day intervals"
    def each_sunday(   n=1, offset=0, dur=1); each_wdays(self.Sun,n,offset,dur); end

    # "every +n+th Monday, starting at +offset+ weeks, +dur+ day intervals"
    def each_monday(   n=1, offset=0, dur=1); each_wdays(self.Mon,n,offset,dur); end

    # "every +n+th Tuesday, starting at +offset+ weeks, +dur+ day intervals"
    def each_tuesday(  n=1, offset=0, dur=1); each_wdays(self.Tue,n,offset,dur); end

    # "every +n+th Wednesday, starting at +offset+ weeks, +dur+ day intervals"
    def each_wednesday(n=1, offset=0, dur=1); each_wdays(self.Wed,n,offset,dur); end

    # "every +n+th Thursday, starting at +offset+ weeks, +dur+ day intervals"
    def each_thursday( n=1, offset=0, dur=1); each_wdays(self.Thu,n,offset,dur); end

    # "every +n+th Friday, starting at +offset+ weeks, +dur+ day intervals"
    def each_friday(   n=1, offset=0, dur=1); each_wdays(self.Fri,n,offset,dur); end

    # "every +n+th Saturday, starting at +offset+ weeks, +dur+ day intervals"
    def each_saturday( n=1, offset=0, dur=1); each_wdays(self.Sat,n,offset,dur); end
    
    
    def wday(wd,offset=0)
      each_wdays(wd,1,offset).limit_to(1)
    end
    
    def sunday(offset=0);    wday(self.Sun,offset); end
    def monday(offset=0);    wday(self.Mon,offset); end
    def tuesday(offset=0);   wday(self.Tue,offset); end
    def wednesday(offset=0); wday(self.Wed,offset); end
    def thursday(offset=0);  wday(self.Thu,offset); end
    def friday(offset=0);    wday(self.Fri,offset); end
    def saturday(offset=0);  wday(self.Sat,offset); end
    
    # multiple day-of-week iterator:
    # "every days of the week +wdays+"
    #
    # For example, 
    #     `range.each_days_of_week(range.Tue, range.Thu)`
    #     # "every Tuesday and Thursday in range"
    #
    # if no parameter passed, identical to each_days
    def each_days_of_week(*wdays)
      if wdays.empty?
        each_days
      else
        each_days.except {|dt| !wdays.include?(dt.wday) }
      end
    end
    alias each_day_of_week each_days_of_week
    
    # every weekday
    def each_weekdays
      each_days_of_week(*self.WEEKDAYS)
    end
    alias each_weekday each_weekdays
    
    # every weekend (Saturday and Sunday)
    def each_weekends
      each_days_of_week(*self.WEEKENDS)
    end
    alias each_weekend each_weekends
    
    # every Friday, Saturday, and Sunday
    def each_weekends_including_friday
      each_days_of_week(*([self.Fri] + self.WEEKENDS))
    end
    alias each_weekend_including_friday each_weekends_including_friday
    
    
    # month iterator:
    # "every +n+ months, starting at +offset+ months, +dur+ month intervals"
    #
    # if no parameters passed,
    #   "every month of range grouped into one-month intervals"
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
    
    def month(offset=0); each_months(1,offset).limit_to(1); end

    # month-of-year iterator:
    # "every +n+th month +nmonth+ grouped into one-month intervals"
    #
    # +nmonth+ is required. Typically, `each_january`, etc. called instead.
    #
    # if +n+ parameter not passed,
    #   "every month number +nmonth+ of range grouped into one-month intervals"
    def each_monthnum(nmonth,n=1)
      build_subrange do |s|
        s.step   = n
        s.adjust_range { |r| day_range(r) }
        s.offset       { |dt| dt >> (nmonth - dt.month)%12 }
        s.increment    { |dt,i| dt.to_date >> i*12 }      
        s.span         { |dt| dt.to_date >> 1 }
      end
    end
    
    # "every +n+th January, grouped into one-month intervals"
    def each_january(  n=1); each_monthnum(self.Jan,n); end

    # "every +n+th February, grouped into one-month intervals"
    def each_february( n=1); each_monthnum(self.Feb,n); end

    # "every +n+th Mary, grouped into one-month intervals"
    def each_march(    n=1); each_monthnum(self.Mar,n); end

    # "every +n+th April, grouped into one-month intervals"
    def each_april(    n=1); each_monthnum(self.Apr,n); end

    # "every +n+th May, grouped into one-month intervals"
    def each_may(      n=1); each_monthnum(self.May,n); end

    # "every +n+th June, grouped into one-month intervals"
    def each_june(     n=1); each_monthnum(self.Jun,n); end

    # "every +n+th July, grouped into one-month intervals"
    def each_july(     n=1); each_monthnum(self.Jul,n); end

    # "every +n+th August, grouped into one-month intervals"
    def each_august(   n=1); each_monthnum(self.Aug,n); end

    # "every +n+th September, grouped into one-month intervals"
    def each_september(n=1); each_monthnum(self.Sep,n); end

    # "every +n+th October, grouped into one-month intervals"
    def each_october(  n=1); each_monthnum(self.Oct,n); end

    # "every +n+th November, grouped into one-month intervals"
    def each_november( n=1); each_monthnum(self.Nov,n); end

    # "every +n+th December, grouped into one-month intervals"
    def each_december( n=1); each_monthnum(self.Dec,n); end
    
    
    # year iterator:
    # "every +n+ years, starting at +offset+ years, +dur+ year intervals"
    #
    # if no parameters passed,
    #   "every year of range grouped into one-year intervals"
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
    
    def year(offset=0); each_year(1,offset).limit_to(1); end
    
    # ---
    
    # day-of-month iterator:
    # "every +nday+th day of the month, grouped into +dur+ day intervals"
    #
    # +nday+ is required.
    #
    # if no +dur+ parameter passed,
    #   "every +nday+th day of the month, grouped into one-day intervals"
    def on_day(nday,dur=1)
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
    
    # time-of-day iterator:
    # "every day at +tm+, grouped into +dur+ second intervals"
    #
    # +tm+ is any string that can be Time.parse'd. Note the date portion is ignored, if given.
    #
    # if no +dur+ parameter passed, intervals are 'instantaneous' time ranges
    def at_time(tm,dur=0)
      tm_p = Time.parse(tm)
      build_subrange do |s|
        s.step    = 60*60*24
        s.adjust_range    { |r| time_range(r) }        
        s.offset          do |tm| 
                               Time.new( 
                                 tm.year,   tm.month, tm.day,
                                 tm_p.hour, tm_p.min, tm_p.sec, (tm + s.step).utc_offset
                               )
                          end
        s.increment       { |tm,i| tm.to_time + i }
        s.span            { |tm| tm.to_time + dur }
      end
    end
      
    # ---
    
    # Helper methods - these are a bit hacky and possibly buggy.
    # Used in iterator `adjust_range` procs to ensure the right data type
    # before iterating
    
    # convert to date range
    # and make exclusive if not already
    # For example,
    #
    #   `2012-02-01..2012-02-29`   becomes
    #   `2012-02-01...2012-03-01`
    #
    # while
    #
    #   `2012-02-01...2012-02-29`  is unmodified.
    #
    def day_range(rng=self)
      if rng.respond_to?(:exclude_end?) && rng.exclude_end?
        Range.new(rng.begin.to_date, rng.end.to_date, true)
      else
        Range.new(rng.begin.to_date, rng.end.to_date + 1, true)
      end
    end
    
    # unless already a time range,
    # convert to exclusive date range, and then to time range
    # For example,
    #
    #   `2012-02-01..2012-02-29`   becomes
    #   `2012-02-01 00:00:00 UTC...2012-03-01 00:00:00 UTC`
    #
    def time_range(rng=self)
      if rng.begin.respond_to?(:sec) && rng.end.respond_to?(:sec)
        rng.dup
      else
        adj_rng = day_range(rng)
        Range.new(adj_rng.begin.to_time, adj_rng.end.to_time, true)
      end
    end
    
    # convenience wrapper for SubRangeIterator.new(self) { ... }
    def build_subrange(&builder)
      SubRangeIterator.new(self, &builder)
    end
    
    # ---
    
    # Iterators are defined by
    #   
    # - `range`:         base range (required)
    # - `step`:          repetition length (default = 1)
    # - `adjust_range`:  proc that adjusts base range before iteration (optional)
    # - `offset`:        proc that adjusts start of adjusted range prior to iteration (optional)
    # - `increment`:     proc that defines scale of each step (required)
    # - `span`:          proc that defines duration of each returned subrange (required)
    # - `except`:        proc(s) that don't yield subrange if true of current step date (but don't stop iteration)
    # - `limit`:         stop iteration after self.limit steps (yields)
    #
    # TODO: 
    # - `until`:    proc that stops iteration if true of current step date
    #
    # Note that SubRangeIterator is coupled to DateTimeRange since it itself includes DateTimeRange (for chaining);
    # However, otherwise it could be used just as well on other (e.g. numeric) ranges
    #
    class SubRangeIterator
      include Enumerable
      include DateTimeRange
      
      attr_accessor :range, :step, :limit
      def step;  @step ||= 1;   end
      
      # a bit hacky - used to extend concrete subranges
      # with the same extensions as the range
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
    
      # note: useful for chaining instead of step=
      def step_by(n)
        self.step = n
        self
      end
      
      # note: useful for chaining instead of limit=
      def limit_to(n)
        self.limit = n
        self
      end
      
      def adjust_range(&p)
        self.range_proc = p
        self
      end
      
      def offset(&p)
        self.offset_proc = p
        self
      end
      
      def increment(&p)
        self.step_proc = p
        self
      end
      
      def span(&p)
        self.span_proc = p
        self
      end
      
      def except(&p)
        exception_procs << p
        self
      end
      
      def cover?(dt)
        any? {|r| r.cover?(dt)}
      end
      
      # Recursive madness...
      # note this could possibly use cached results stored by #all method,
      # similar to Sequel
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
      
      # Iteration
      # 1. adjust base range
      # 2. get offset
      # 3. for each step,
      #    3.1. if limit reached, break
      #    3.2. find begin of next subrange (step_proc)
      #    3.3. find end of next subrange (span_proc)
      #    3.4. check if begin in adjusted base range, stop iteration if not
      #    3.5. check if begin matches any exceptions (exception_procs)
      #         3.5.1 if not, increment the yield count (i)
      #         3.5.2 and yield the subrange, extended with same modules as base range
      def each_by_step(rng=self.range)
        rng = range_proc.call(rng)
  #      puts "each_by_step range: #{rng}"
        initial = offset_proc.call(rng.begin)
        i=0
        by_step(self.step).each do |n|
          break if self.limit && self.limit <= i
          next_begin = step_proc.call(initial,n)
          next_end   = span_proc.call(next_begin)
          if rng.respond_to?(:cover?) && !rng.cover?(next_begin) 
            raise StopIteration
          end
          unless exception_procs.any? {|except| except.call(next_begin)}
            i+=1
            yield((next_begin...next_end).extend(*range_extensions))
          end
        end
      end
      
      # 'stateless' step enumerator
      # simply generates infinite integer sequence
      # if ruby already has such a facility built-in, let me know
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
      def offset_proc
        @offset_proc ||= lambda {|dt| dt}
      end
      
      def exception_procs; @exception_procs ||= []; end
      
    end
    
  end

end


if $0 == __FILE__

  require 'pp'
  
   range = (Date.civil(2012,1,1)...Date.civil(2013,1,1)).extend(Tempr::DateTimeRange)
   subrange = range.each_month.thursday(2).at_time('2:00pm',60*60)

   pp subrange.to_a
      
end