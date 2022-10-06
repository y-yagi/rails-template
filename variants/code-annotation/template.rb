# Allow us to copy file with root at the directory this file is in
source_paths.unshift(File.dirname(__FILE__))

TERMINAL.puts_header "Installing code annotation gems"

insert_into_file "Gemfile", after: /group :development do\n/ do
  <<-GEMS
  # code annotation
  gem "chusaku", require: false
  gem "annotate", require: false

  GEMS
end

run "bundle install"

# adds a rake task which causes annotate to auto-run on every migration
run "bundle exec rails generate annotate:install"

run "bundle exec rubocop -A lib/tasks/auto_annotate_models.rake"

TERMINAL.puts_header "Annotating code"

run "bundle exec chusaku"
run "bundle exec annotate"

TERMINAL.puts_header "Commiting code annotations to git"

git add: "-A ."
git commit: "-n -m 'Set up Ruby code annotation'"
