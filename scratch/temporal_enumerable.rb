require 'time'
require 'date'

module TemporalEnumerable

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
  
  #---------------- step by seconds
  def each_seconds(n=1, off=0, &b)
    t0 = self.begin.to_time
    each_by_step(n, off, t0, lambda{|t,i| t+i}, &b)
  end
  alias each_second each_seconds
  
  def second(n)
    time = nil
    each_second(1,n) {|t| time = t; break}
    time
  end
  
  def each_minutes(n=1, off=0, &b)
    each_seconds(n*60, off*60, &b)
  end
  alias each_minute each_minutes
  
  def minute(n)
    time =nil
    each_minute(1,n) {|t| time = t; break}
    time
  end
  
  def each_hours(n=1, off=0, &b)
    each_seconds(n*60*60, off*60*60, &b)
  end
  alias each_hour each_hours
  
  def hour(n)
    time = nil
    each_hour(1,n) {|t| time = t; break}
    time
  end
  
  # -----
  
  # step by days
  def each_days(n=1, off=0, &b)
    d0 = self.begin.to_date
    each_by_step(n, off, d0, lambda{|t,i| t+i}, &b)
  end
  alias each_day each_days
  
  def day(n)
    dt = nil
    each_day(1,n) {|t| dt = t; break}
    dt
  end
  
  def each_weeks(n=1, off=0, &b)
    each_days(n*7, off*7, &b)
  end
  alias each_week each_weeks
  
  def week(n)
    dt = nil
    each_week(1,n) {|t| dt = t; break}
    dt
  end
  
  # -----
  
  # step by weeks on a specific weekday
  def each_wdays(wd, n=1, off=0, &b)
    d0 = self.begin.to_date
    d0+=((wd-d0.wday)%7)
    each_by_step(n*7, off*7, d0, lambda {|d,i| d + i}, &b)
  end
  alias each_wday each_wdays
  
  def wday(wd, n)
    dt = nil
    each_wday(wd,1,n) {|t| dt = t; break}
    dt
  end
  
  def each_sunday(   n=1, off=0, &b); each_wdays(Sun,n,off,&b); end
  def each_monday(   n=1, off=0, &b); each_wdays(Mon,n,off,&b); end
  def each_tuesday(  n=1, off=0, &b); each_wdays(Tue,n,off,&b); end
  def each_wednesday(n=1, off=0, &b); each_wdays(Wed,n,off,&b); end
  def each_thursday( n=1, off=0, &b); each_wdays(Thu,n,off,&b); end
  def each_friday(   n=1, off=0, &b); each_wdays(Fri,n,off,&b); end
  def each_saturday( n=1, off=0, &b); each_wdays(Sat,n,off,&b); end
  
  def sunday(   n); wday(Sun,n); end
  def monday(   n); wday(Mon,n); end
  def tuesday(  n); wday(Tue,n); end
  def wednesday(n); wday(Wed,n); end
  def thursday( n); wday(Thu,n); end
  def friday(   n); wday(Fri,n); end
  def saturday( n); wday(Sat,n); end

  # -----
  
  # step by months
  def each_months(n=1, off=0, &b)
    d0 = self.begin.to_date
    each_by_step(n, off, d0, lambda {|d,i| d >> i}, &b)
  end
  alias each_month each_months
  
  def month(n)
    dt = nil
    each_month(1,n) {|t| dt = t; break}
    dt
  end
  
  # -----
  
  # step by years
  def each_years(n=1, off=0, &b)
    d0 = self.begin.to_date
    each_by_step( n, off, d0, 
                  lambda {|d,i| Date.civil(d.year + i,d.month,d.day)},
                  &b
                )  
  end
  alias each_year each_years
  
  def year(n)
    dt = nil
    each_year(1,n) {|t| dt = t; break}
    dt
  end
  
  # -----
  
  # date/time range intersection
  
  def intersection(other, precision=0)
    if ( self.begin.respond_to?(:seconds) &&  self.end.respond_to?(:seconds)) ||
       (other.begin.respond_to?(:seconds) && other.end.respond_to?(:seconds))
      time_intersection(other,precision)

    elsif ( self.begin.respond_to?(:days) &&  self.end.respond_to?(:days)) ||
          (other.begin.respond_to?(:days) && other.end.respond_to?(:days))
      date_intersection(other,precision)
    
    else
      raise TypeError
    end
  end
  
  def & (other)
    intersection(other)
  end
  
  def time_intersection(other, precision=0)
    trange1 = fuzz_time_range(self, precision)
    trange2 = fuzz_time_range(other,precision)
    b = [trange1.begin,trange2.begin].max
    e = [trange1.end  ,trange2.end  ].min
    if e < b
      nil..nil
    else
      Range.new(b, e, self.exclude_end? && precision==0)
    end
  end
  
  def date_intersection(other, precision=0)
    drange1 = fuzz_date_range(self, precision)
    drange2 = fuzz_date_range(other,precision)
    b = [drange1.begin,drange2.begin].max
    e = [drange1.end  ,drange2.end  ].min
    if e < b
      nil..nil    # not sure this is the best way
    else
      Range.new(b, e, self.exclude_end? && precision==0).extend(self.class)
    end 
  end
  
  # probably should be private
  def fuzz_time_range(range,precision)
    if range.respond_to?(:begin) && range.respond_to?(:end)
      Range.new(range.begin.to_time - precision,
                range.end.to_time   + precision,
                range.exclude_end?
               )
    else
      Range.new(range.to_time - precision,
                range.to_time + precision,
                false
               )
    end    
  end

  # probably should be private
  def fuzz_date_range(range,precision)
    if range.respond_to?(:begin) && range.respond_to?(:end)
      Range.new(range.begin.to_date - precision,
                range.end.to_date   + precision,
                range.exclude_end?
               )
    else
      Range.new(range.to_date - precision,
                range.to_date + precision,
                false
               )
    end    
  end
  
  private
  
  # generic time/date iteration using step enumerator below
  def each_by_step(n,offset,initial,step_proc)
    accum = []
    offset_init = step_proc.call(initial,offset)
    by_step(n).each do |step|
      next_val = step_proc.call(offset_init,step)
      if self.respond_to?(:end) && self.end && next_val > self.end
        raise StopIteration
      end
      block_given? ? yield(next_val) : accum << next_val
    end
    block_given? ? nil : accum
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
  
end
 
  
class Schedule
  include Enumerable
  
  attr_reader :events
  def events; @events ||= []; end
  
  def add_event(event, time=nil, duration={}, &expr)
    e = Event.new(event,time,duration,&expr)
    events << e
    e
  end

  # Probably, we should set range as a state of the schedule
  # rather than pass it in to each of these methods
  
  def each(range,&b)
    events.each(range,&b)
  end
  
  # each event with at least one date in the passed range
  # normally you would not use this unless you just need a list of event names
  # instead use #in for more flexibility
  def events_in(range)
    events.reject {|event| 
      event.each(range).count == 0
    }
  end
  
  # schedule records for the passed range
  def in(range)
    events.inject([]) {|memo,event|
      dts = event.each(range).to_a
      unless dts.empty?
        rec = schedule_record.new
        rec.event = event
        rec.dates = dts
        memo << rec
      end
      memo
    }
  end
  
  # TODO
  def conflicts_in(range)
  end
  
  def schedule_record
    @schedule_record ||= Struct.new(:event, :dates)
  end
  
  # TODO: events need duration or internal time range
  class Event
    include Enumerable
    
    attr_accessor :name
    
    def initialize(name, time=nil, mods={}, &cond)
      self.name      = name
      self.precision = mods.delete(:precision) || 0
      schedule(&cond)
    end
    
    def or(time=nil, mods={}, &cond)
      cond ||= lambda {|range| 
                  subrange = event_range(time,mods) 
                  range.intersection(subrange, self.precision)
               }
      stack << cond
      self
    end
        
    def schedule(time=nil, mods={}, &cond)
      init_stack; self.or(time, mods, &cond)
    end
    
    def each(range,&b)
      stack.inject([]) do |results,cond|
        results | cond.call(range)
      end.each(&b)
    end
    alias each_date each
        
    def include_date?(dt, range)
      !!stack.find {|cond| cond.call(range).include?(dt)}
    end
    alias include_time? include_date?
    
    def to_s
      "#{name} (#{stack.size} conditions)"
    end
    
    def event_range(time,mods)
      dur = 
    end
    
    
    private
    
    attr_reader :stack
    def stack; @stack ||= []; end
    def init_stack; @stack = nil; stack; end
   
    
  end
  
end

if $0 == __FILE__

  require 'pp'
  
  container = Struct.new(:begin, :end).send(:include, TemporalEnumerable)
  
  dt = container.new(Time.now)
  
  puts 'every hour until the next midnight'
  dt.each_hour do |t| break if t.day != dt.begin.day && t.hour == 0; puts t end
  puts
  
  puts 'every hour starting 2 hours from now, until the next midnight'
  dt.each_hours(1,2) do |t| break if t.day != dt.begin.day && t.hour ==0; puts t end
  puts
  
  puts 'the fourth hour from now'
  puts dt.hour(4)
  puts
  
  puts 'every 2 weeks from now until March'
  dt.each_weeks(2) do |t| break if t.month == 3; puts t end
  puts 
  
  puts 'every week starting 2 weeks from now until May'
  dt.each_weeks(2,2) do |t| break if t.month == 5; puts t end
  puts
  
  dt2 = container.new(Date.today, Date.civil(Date.today.year + 10, Date.today.month, Date.today.day))
  
  puts 'every 3 months until 10 years from today'
  dt2.each_months(3) do |d| puts d end
  puts
  
  puts 'every year until 10 years from today, starting next year'
  dt2.each_year(1,1) do |d| puts d.year end
  puts
  
  puts 'first Wed in March 2012'
  # obviously you'd want a more useful container than this that just takes a year and month
  dt3 = container.new(Date.civil(2012,3,1), Date.civil(2012,3,31))
  puts dt3.each_wednesday.first
  puts
  
  puts 'second and fourth Friday in March-April 2012'
  dt4 = container.new(Date.civil(2012,4,1), Date.civil(2012,4,30))
  puts dt3.each_friday(2,1) | dt4.each_friday(2,1)
  puts
  
  # using a range
  puts 'first Wed in April 2012, using a range'
  dt5 = (Date.civil(2012,4,1)..Date.civil(2012,4,30)).extend(TemporalEnumerable)
  puts dt5.each_wednesday.first
  puts
  
  puts 'scheduling a meeting every other wednesday and the 3rd thursday and every thursday following'
  puts 'and two appointments, one of which is in the next month'
  puts 'here is the schedule of events for April 2012'
  sched = Schedule.new
  evt = Schedule::Event.new("meeting") do |range| 
           range.each_wednesday(2) 
         end.or do |range| 
           range.each_thursday(1,2)
         end
  sched.events << evt
  sched.add_event("appointment", Time.utc(2012,4,15,14,30))
  sched.add_event("next month", Time.utc(2012,5,15,14,30))
 
  pp sched.in(dt5)
  puts
  
  puts 'in April, meeting events'
  pp sched.events_in(dt5).select {|evt| evt.name == 'meeting'} 
  puts
  
  puts 'in April, is there an event Wed April 4, 2012?'
  puts sched.events.first.include_date?(Date.civil(2012,4,4), dt5)
  puts 

  dt6 = (Date.civil(2012,5,1)..Date.civil(2012,5,31)).extend(TemporalEnumerable)
  
  puts 'in May, is there an event Wed May 2, 2012?'  
  puts sched.events.first.include_date?(Date.civil(2012,5,2), dt6)
  puts 
  
  puts 'in May, is there an event May 15, 2012 at 14:30?'  
  puts sched.events.first.include_time?(Time.utc(2012,5,15,14,30), dt6)
  puts 
  
end
  
