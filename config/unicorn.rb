rails_env = ENV['RAILS_ENV'] || 'production'  
  
worker_processes 30 
  
preload_app true  
  
timeout 360  
  
socket_path = '/Library/WebServer/topfind/tmp/sockets/unicorn.sock'  
pid_path = '/Library/WebServer/topfind/tmp/pids/unicorn.pid'
log_path = '/Library/WebServer/topfind/log/'

# listen on both a Unix domain socket and a TCP port,
# we use a shorter backlog for quicker failover when busy
listen 4000, :tcp_nopush => true, :backlog => 10048 
#listen socket_path, :backlog => 2048  
pid pid_path  

# By default, the Unicorn logger will write to stderr.
# Additionally, ome applications/frameworks log to stderr or stdout,
# so prevent them from going to /dev/null when daemonized here:
stderr_path "#{log_path}unicorn.stderr.log"
stdout_path "#{log_path}unicorn.stdout.log"

  

