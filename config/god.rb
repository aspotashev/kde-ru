# see Railscasts 243: beanstalkd and stalker; Railscasts 130: monitoring with god
RAILS_ROOT = File.expand_path("../..", __FILE__)

def generic_monitoring(w, options = {})
  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.running = false
    end
  end

  w.restart_if do |restart|
    restart.condition(:memory_usage) do |c|
      c.above = options[:memory_limit]
      c.times = 5
    end
  end

  w.lifecycle do |on|
    on.condition(:flapping) do |c|
      c.to_state = [:start, :restart]
      c.times = 5
      c.within = 5.minute
      c.transition = :unmonitored
      c.retry_in = 10.minutes
      c.retry_times = 5
      c.retry_within = 2.hours
    end
  end
end

God.watch do |w|
  w.name = "stalk-general-jobs"
  w.interval = 30.seconds
  w.env = {"RAILS_ENV" => "production"} # does it work with Rails 2.3.10?
  w.start = "/usr/bin/stalk #{RAILS_ROOT}/app/jobs/jobs.rb"
  w.log = "#{RAILS_ROOT}/log/stalker.log"

  generic_monitoring(w, :memory_limit => 70.megabytes)
end

God.watch do |w|
  w.name = "po-backend-drb"
  w.interval = 30.seconds
  w.start = "#{RAILS_ROOT}/vendor/po-backend/server.rb"
  w.log = "#{RAILS_ROOT}/log/po-backend.log"

  generic_monitoring(w, :memory_limit => 40.megabytes) # usually it takes 30 MB
end

God.watch do |w|
  w.name = "beanstalkd"
  w.interval = 1.hour
  w.start = "beanstalkd"
  w.log = "#{RAILS_ROOT}/log/beanstalkd.log"

  generic_monitoring(w, :memory_limit => 5.megabytes)
end
