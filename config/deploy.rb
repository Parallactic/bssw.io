# frozen_string_literal: true

set :rvm_ruby_version, '3.2.0'

# set :bundle_dir, ''
# set :bundle_flags, '--system --quiet'

set :application, 'bss'
set :repo_url, 'git@github.com:Parallactic/bssw.io.git'

set :branch, ENV['BRANCH'] || 'main'

# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/my_app_name"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

set :linked_dirs,
    fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system',
                                 'public/uploads',
                                 'config/credentials')
set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

namespace :deploy do
  after :finishing, :notify do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      within release_path do
        execute :bundle, 'exec rake db:migrate RAILS_ENV=preview'
        execute :bundle,
                "exec rails runner -e #{fetch(:rails_env)} 'RebuildStatus.code_branch=(\"#{fetch(:branch)}\") '"
        execute :bundle, "exec rails runner -e preview 'RebuildStatus.code_branch=(\"#{fetch(:branch)}\") '"
      end
    end
  end
end

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

# namespace :deploy do
#   after :finishing, :notify do
#     on roles(:web), in: :groups, limit: 3, wait: 10 do
#       # Here we can do anything such as:
#       # within release_path do
#       #   execute :rake, 'cache:clear'
#       # end
#       within release_path do
# #            execute :bundle, "exec rake sunspot:solr:stop RAILS_ENV=#{fetch(:rails_env)} "
#               execute :bundle, "exec rake sunspot:solr:reindex RAILS_ENV=#{fetch(:rails_env)}"

#       execute :bundle, "exec rake sunspot:solr:start RAILS_ENV=#{fetch(:rails_env)}"
#       end
#     end
#   end

# end
