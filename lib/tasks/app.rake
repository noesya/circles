namespace :app do
  desc 'Sync'
  task :sync do
    AllUsersSyncJob.perform_later
  end

  # FIXME @SebouChu help! La tâche ne fonctionne pas, c'est peut-être une histoire de plan Scalingo insuffisant ?
  namespace :db do
    desc 'Get database from Scalingo'
    task :production do
      Bundler.with_unbundled_env do
        Dotenv.load
        # Get a new backup archive from Scalingo
        # PG Addon ID from `scalingo addons` CLI command.
        sh "scalingo --app #{ENV['SCALINGO_APP_NAME']} backups-create --addon #{ENV['SCALINGO_PG_ADDON_ID']}"
        sh "scalingo --app #{ENV['SCALINGO_APP_NAME']} backups-download --addon #{ENV['SCALINGO_PG_ADDON_ID']} --output db/scalingo-dump.tar.gz"

        sh 'rm -f db/latest.dump' # Remove an old backup file if it exists
        sh 'tar zxvf db/scalingo-dump.tar.gz -C db/' # Extract the new backup archive
        sh 'rm db/scalingo-dump.tar.gz' # Remove the backup archive
        sh 'mv db/*.pgsql db/latest.dump' # Rename the backup file
        return
        sh 'DISABLE_DATABASE_ENVIRONMENT_CHECK=1 bundle exec rails db:drop'
        sh 'bundle exec rails db:create'
        begin
          sh 'pg_restore --verbose --clean --no-acl --no-owner -h localhost -U postgres -d circles_development db/latest.dump'
        rescue
          'There were some warnings or errors while restoring'
        end
        sh 'rails db:migrate'
        sh 'rails db:seed'
      end
    end
  end
end
