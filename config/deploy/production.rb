server "178.159.44.152", user: "deploy", roles: %w[app db web], port: 2200
set :branch, "main"        # нужная ветка (поменяй если другая)
set :rails_env, "production"