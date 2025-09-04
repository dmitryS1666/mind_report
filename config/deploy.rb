# config valid for current version and patch releases of Capistrano
lock "~> 3.19.2"

set :application, "mind_report"
set :repo_url, "git@github.com:dmitryS1666/mind_report.git"

set :deploy_to, "/home/deploy/apps/#{fetch(:application)}"

set :default_env, { 'PATH' => "/home/deploy/.asdf/shims:/home/deploy/.asdf/bin:$PATH" }

append :linked_files, "config/master.key", ".env"
append :linked_dirs,  "log", "tmp/pids", "tmp/cache", "tmp/sockets", "storage", "vendor/bundle", "public/assets"

set :keep_releases, 5

namespace :sidekiq do
  desc "Restart sidekiq"
  task :restart do
    on roles(:app) do
      execute :sudo, "-n", :systemctl, :restart, "sidekiq-mind_report"
    end
  end
end

after "deploy:published", "sidekiq:restart"

namespace :deploy do
  desc "Make release & shared assets readable by nginx"
  task :fix_permissions do
    on roles(:app) do
      execute :chmod, "-R", "a+rX", release_path
      execute :chmod, "755", release_path
      execute :chmod, "755", shared_path
      execute :chmod, "755", shared_path.join("public")
      execute :chmod, "-R", "a+rX", shared_path.join("public/assets")
    end
  end
end

after "deploy:published", "deploy:fix_permissions"