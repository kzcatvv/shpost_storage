# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#

env :PATH, ENV['PATH']
env :GEM_PATH, ENV['GEM_PATH']

set :output, "log/cron_log.log"


#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

every :day, :at => '11:07am' do
# every '* * * * *' do
  rake "transmitter:csb:get_point_order"
end

every :day, :at => '05:10pm' do
  rake "transmitter:csb:order_status"
end

every :day, :at => '05:10pm' do
  rake "transmitter:csb:update_order_status"
end

every :day, :at => '13:07am' do
# every '* * * * *' do
  rake "transmitter:csb:redeal_with_orders"
end

every 12.hours do
  rake "transmitter:gnxb:order_query"
end

every 12.hours do
  rake "transmitter:tcbd:order_query"
end
# Learn more: http://github.com/javan/whenever
