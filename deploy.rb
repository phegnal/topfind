namespace :deploy do  
  task :stop, :roles => :app do  
  run "kill -QUIT `cat tmp/pids/unicorn.pid`"  
end   
  
task :start, :roles => :app do  
  run "unicorn_rails -c config/unicorn.rb -E production -D"  
end  
  
desc "restart unicorn"  
task :restart, :roles => :web do  
  run "[ -f tmp/pids/unicorn.pid ] && kill -USR2 `cat tmp/pids/unicorn.pid` || unicorn_rails -c config/unicorn.rb -E production -D --prefix /topfind"  
end 
end
