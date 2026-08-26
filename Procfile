web: bundle exec puma -C config/puma.rb
worker: bundle exec good_job start --max-threads=1
postdeploy: rails db:migrate && rails db:seed
