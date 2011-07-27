require 'delayed/command'

Delayed::Worker.max_attempts = 1

DELAYED_JOB_PID_PATH = "#{Rails.root}/tmp/pids/delayed_job.pid"

def start_delayed_job
  Delayed::Command.new(['start']).daemonize
end

def daemon_is_running?
  pid = File.read(DELAYED_JOB_PID_PATH).strip
  Process.kill(0, pid.to_i)
  true
rescue Errno::ENOENT, Errno::ESRCH   # file or process not found
  false
end

start_delayed_job unless daemon_is_running?
