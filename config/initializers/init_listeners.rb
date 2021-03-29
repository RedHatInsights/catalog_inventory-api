# Be sure to restart your server when you modify this file.

if !defined?(::Rails::Console) && ENV['SCHED_TASK'].nil?
  Events::IngressListener.new(:host => ClowderConfig.queue_host, :port => ClowderConfig.queue_port).run
  Events::SourceListener.new(:host => ClowderConfig.queue_host, :port => ClowderConfig.queue_port).run
  Events::TowerOperationListener.new(:host => ClowderConfig.queue_host, :port => ClowderConfig.queue_port).run
end
