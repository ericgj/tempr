%w[ time_subrange 
    each_time_of_day 
    range_within_other
  ].each do |test|
      require File.expand_path(test,File.dirname(__FILE__))
    end