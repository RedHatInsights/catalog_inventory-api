#
# Usage: bundle exec rake 'cleanup:tasks'   #same as 'cleanup:tasks[7]'
# Usage: bundle exec rake 'cleanup:tasks[days]'
#
require 'rake'

namespace :tasks do
  desc "Cleanup tasks older than specified days"
  task :cleanup, [:days] => [:environment] do |_t, args|
    days = (args.days || 7).to_i

    if days.zero?
      puts "Not allowed to delete all tasks"
      exit
    end

    tasks = Task.where("created_at < ?", Time.zone.today - days)
    puts "#{tasks.count} tasks older than #{days} days will be deleted: #{tasks.pluck(:id)}"
    tasks.destroy_all
  end
end
