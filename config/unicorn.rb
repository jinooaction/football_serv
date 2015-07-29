root = "/home/deployer/apps/football_serv/current"
working_directory root
pid "#{root}/tmp/pids/unicorn.pid"
stderr_path "#{root}/log/unicorn_error.log"
stdout_path "#{root}/log/unicorn_access.log"

listen "/tmp/unicorn.football_serv.sock"
worker_processes 5
timeout 60
