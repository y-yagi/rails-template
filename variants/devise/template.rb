# Allow us to copy file with root at the directory this file is in
source_paths.unshift(File.dirname(__FILE__))

##
# This template can be used either as part of starting a new Rails project or
# by running:
#
#     bundle exec rails app:template LOCATION=http://path/to/this/template.rb
#
def ask_with_default(question, color, default)
  question = (question.split("?") << " [#{default}]?").join
  answer = ask(question, color)
  answer.to_s.strip.empty? ? default : answer
end

def print_header(msg)
  puts "=" * 80
  puts msg
  puts "=" * 80
end

print_header "Adding devise to Gemfile"
run "bundle add devise"

print_header "Running devise generator"
run "bundle exec rails generate devise:install"

print_header "Generating User model with devise"
run "bundle exec rails generate devise User"

print_header "Running db migration"
run "bundle exec rails db:migrate"

print_header "Copying devise views into the application"
run "bundle exec rails generate devise:views users"

##
# Tweak the generated devise config file
#
print_header "Tweaking config/initializers/devise.rb"

mail_sender =  ask_with_default("What 'From:' addresss should this app use for emails from Devise?", :blue, "change-me@example.com")

gsub_file "config/initializers/devise.rb",
          "  config.mailer_sender = 'please-change-me-at-config-initializers-devise@example.com'",
          "  config.mailer_sender = '#{mail_sender}'"

gsub_file "config/initializers/devise.rb",
          "  # config.scoped_views = false",
          "  config.scoped_views = true"

gsub_file "config/initializers/devise.rb",
          "  config.password_length = 6..128",
          "  config.password_length = 8..128"

##
# Add a block to config/routes.rb demonstrating how to create authenticated
# routes
#
print_header "Adding exemplar authenticated routes"
route <<-EO_ROUTES

  authenticate :user do
    # routes created within this block can only be accessed by a user who has
    # logged in. For example:
    # resources :things
  end

EO_ROUTES

##
# Add links to user sign-in and sign-up to the homepage to help ensure that
# devs know they have both things enabled in the application now.
#
print_header "Adding example devise links to the homepage"
gsub_file "app/views/layouts/application.html.erb",
  "<body>",
  <<~ERB
    <body>

    <%
    # This block uses the "style" attribute to make it easy for you to
    # delete. This isn't a suggestion that inline styles are a good idea
    # mmmkay.
    %>
    <nav style="border: 1px solid #666; padding: 1em;">
    <h1>Example devise nav</h1>
    <ul>
      <li>
        <%= link_to "Home", root_path %>
      </li>
    </ul>
    <% if current_user %>
      <p>
      You are <span style="color: green">Signed in</span>
      </p>
      <ul>
        <li>
          <%= link_to "Sign out", destroy_user_session_path, method: :delete %>
        </li>
      </ul>
    <% else %>
      <p>
      You are <span style="color: darkred">Not signed in</span>
      </p>
      <ul>
        <li>
          <%= link_to "Sign in", new_user_session_path %>
        </li>
        <li>
          <%= link_to "Sign up", new_user_registration_path %>
        </li>
      </ul>
    <% end %>
    </nav>
  ERB


print_header "Writing tests for you - you're welcome!"

copy_file "spec/models/user_spec.rb", force: true

copy_file "spec/factories/users.rb", force: true

copy_file "spec/system/user_sign_in_feature_spec.rb"
copy_file "spec/system/user_sign_up_feature_spec.rb"
copy_file "spec/system/user_reset_password_feature_spec.rb"

if ask_with_default("Do you want to create a git commit with these changes?",
                    :yellow,
                    "N").downcase.start_with?("y")
  git add: "-A ."
  git commit: "-n -m 'Install and configure devise with default Ackama settings'"
end