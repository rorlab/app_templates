########################################
# File : minitest-template.rb
# Author : Lucius Choi, ROR Lab.
# Created at : October 3, 2014
########################################

# Minitest 자동화를 위한 젬 설치
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

# test/test_helper.rb 파일에 minitest-reporters 젬 설정 추가하기
insert_into_file 'test/test_helper.rb', "\nrequire 'minitest/reporters'\nMinitest::Reporters.use!\n", after: "require 'rails/test_help'\n"

# Guardfile 생성
run "bundle exec guard init minitest"

# spring: true 옵션 추가
# gsub_file "Guardfile", /^(guard :minitest.*)\s(do.*)$/,'\1, spring: true \2'

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
