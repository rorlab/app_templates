########################################
# File : devise_auth_template.rb
# Author : Lucius Choi, ROR Lab.
# Created at : October 4, 2014
########################################

# 설치한 젬 리스트
gems = %w{ bootstrap-sass autoprefixer-rails font-awesome-rails simple_form country_select devise rolify authority }

# 오프닝 메시지
say "\n> DEVISE_AUTH_TEMPLATE.rb\n\n"
say "Are you ready?\n\n"
say "It will include the following gems:\n\n"
gems.each { | gem_name | say "\t* #{gem_name}" }
say "\n"
say "And some application options will be setup.\n\n"
say "Let's get stated~\n\n"

# Gemfile에 젬 추가
gems.each do | gem_name |
  if yes?("Do you want to use the '#{gem_name}' gem? [y|n] ")
    if yes?("Do you want to use the latest version of '#{gem_name}' gem? [y|n]")
      gem gem_name
    else
      gem_ver = ask("Which version of '#{gem_name}' do you want? [ex.: 3.3.0]")
      if gem_ver.blank?
        gem gem_name
      else
        gem gem_name, "~> #{gem_ver}"
      end
    end
  end
end

gem_group :development do
  gem 'letter_opener'
end

# Minitest 자동화를 위한 젬 설치
say "Some gems for the automation of Minitest will be added and setup."
gem_group :development do
  gem 'guard-minitest'
  gem 'minitest-reporters'
end
gem_group :test do
  gem 'minitest'
  gem 'mini_backtrace'
end

# bundle 설치
run "bundle install"

#########################
# Bootstrap 설정
#########################

if yes?("Do you want to set up the assets and layout for Bootstrap? [y|n]")
  # application.css.scss 파일 생성 후, bootstrap-sprockets.css 파일 추가
  inside 'app/assets/stylesheets' do
    remove_file 'application.css'
    create_file 'application.css.scss' do
      "@import 'bootstrap-sprockets';\n@import 'bootstrap';\n@import 'bootstrap/theme';\n@import 'font-awesome';\n\n.alert { margin-top: 1em;}\nbody { padding: 5em 0 2em; }"
    end
  end

  # bootstrap.js 추가
  inside 'app/assets/javascripts' do
    insert_into_file 'application.js', "//= require bootstrap-sprockets\n", after: "//= require jquery\n"
  end

  # flash_box 헬퍼 메소드 추가
  inside 'app/helpers' do
    remove_file 'application_helper.rb'
    get 'https://gist.githubusercontent.com/rorlab/b8b2ca966867d5839bdf/raw/45e7cee9c7af7a0ac1c5b7f00d8194d161c36221/application_helper.rb'
  end

  # 어플리케이션 레이아웃 파일 업데이트
  inside 'app/views/layouts' do
    remove_file "application.html.erb"
    get 'https://gist.githubusercontent.com/rorlab/bdc7763ffacc5ac9acd7/raw/afd0003e6f42faed891485c0ec379c8f63d7de58/application.html.erb'
  end
  # inside 'app/views/layouts' do
  #   insert_into_file 'application.html.erb', "\t<div class='container'>\n\t\t<%= flash_box(flash) %>\n\t\t", before: "<%= yield %>"
  #   insert_into_file 'application.html.erb', "\n\t</div>", after: "<%= yield %>"
  # end
end

# Welcome 컨트롤러 및 index 액션 생성
if yes?("Do you want to create 'Welcome' controller and its 'index' action? [y|n]")
  generate "controller", "welcome index"

  # routes.rb 업데이트
  route "root 'welcome#index'"
  comment_lines 'config/routes.rb', /get 'welcome\/index'/
end


#########################
# Simple_form 셋업
#########################
if yes?("Do you want to install simple_form for bootstrap? [y|n]")
  generate 'simple_form:install', '--bootstrap'
  remove_file 'lib/templates/erb/scaffold/_form.html.erb'
  get 'https://gist.githubusercontent.com/rorlab/911efc2e2e5791eb49ba/raw/f2f0897f9a5d8c23b362914c5cc5513a358e01de/_form.html.erb', 'lib/templates/erb/scaffold/_form.html.erb'
end


#########################
# Devise 셋업
#########################
generate 'devise:install'
generate 'devise', 'User'
generate 'devise:views', 'users'
application(nil, env: "development") do
  "\nconfig.action_mailer.default_url_options = { host: 'localhost', port: 3000 }\n\tconfig.action_mailer.delivery_method = :letter_opener\n"
end
rake 'db:migrate'

#########################
# Test 자동화 셋업
#########################

# test/test_helper.rb 파일에 minitest-reporters 젬 설정 추가하기
insert_into_file 'test/test_helper.rb', "\nrequire 'minitest/reporters'\nMinitest::Reporters.use!\n", after: "require 'rails/test_help'\n"

# Guardfile 생성
run "bundle exec guard init minitest"

# spring: true 옵션 추가
gsub_file "Guardfile", /^(guard :minitest.*)\s(do.*)$/,'\1, spring: true \2'

# Rails 4 옵션 추가
insert_into_file 'Guardfile', %{
  # Rails 4
  watch(%r{^app/(.+)\.rb$})                               { |m| "test/\#{m[1]}_test.rb" }
  watch(%r{^app/controllers/application_controller\.rb$}) { 'test/controllers' }
  watch(%r{^app/controllers/(.+)_controller\.rb$})        { |m| "test/integration/\#{m[1]}_test.rb" }
  watch(%r{^app/views/(.+)_mailer/.+})                   { |m| "test/mailers/\#{m[1]}_mailer_test.rb" }
  watch(%r{^lib/(.+)\.rb$})                               { |m| "test/lib/\#{m[1]}_test.rb" }
  watch(%r{^test/.+_test\.rb$})
  watch(%r{^test/test_helper\.rb$})                       { 'test' }
  }, before: "\n  # Rails < 4"

say("\n")
say("==============================================================")
say("[Info] Completed Automation of Minitest with Guard!!!")
say("================================================================\n\n")

if yes?("Do you want to git init and commit this project? [y|n]")
  git :init
  git :add => "."
  git :commit => "-a -m 'Initial commit'"
end

say("\n\n^^ Mission completed! >>>>\n\n")
say("Now, bundling...")
