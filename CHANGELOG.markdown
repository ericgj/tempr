# Changelog

## 0.1.4 / 2012-02-20

- add range adjacency methods (`precedes?`, `succeeds?`, `adjacent_to?`)

## 0.1.3 / 2012-02-19

- convert date to time ranges for date <-> time comparisons in `within?/subsume?/intersection_with`
- fix behavior with exclusive ranges
- add test cases, DRY up tests
- add Rakefile, add rake to gemspec

## 0.1.2 / 2012-02-19

- add `within?`, `subsume?`, `intersection_with`, `intersects?`

## 0.1.1 / 2012-02-18

- add `SubRangeIterator#cover?` shortcut
- add `between_times`
- `on_day` renamed `each_day_of_month`; deprecation warning
- `at_time` renamed `each_time_of_day`; deprecation warning
- add utc_offset param to `each_time_of_day`, `time_range`
- fix error where time subranges forced to local time

## 0.1.0 / 2012-02-16

- Initial gem release
