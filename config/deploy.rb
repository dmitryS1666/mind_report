# config valid for current version and patch releases of Capistrano
lock "~> 3.19.2"

set :application, "mind_report"
set :repo_url, "git@github.com:dmitryS1666/mind_report.git"

set :deploy_to, "/home/deploy/apps/#{fetch(:application)}"

set :default_env, { 'PATH' => "/home/deploy/.asdf/shims:/home/deploy/.asdf/bin:$PATH" }

append :linked_files, "config/master.key", ".env"
append :linked_dirs,  "log", "tmp/pids", "tmp/cache", "tmp/sockets", "storage", "vendor/bundle"

set :keep_releases, 5