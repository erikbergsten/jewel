from ruby:3.4.7

workdir /jewel

copy Gemfile .
copy Gemfile.lock .

run bundle install

copy src src

workdir /work

cmd ["ruby", "/jewel/src/repl.rb"]
