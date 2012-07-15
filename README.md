# Jist: A Rails clone of [GitHub Gist](http://gist.github.com)

## Install

```
$ git clone https://github.com/garethrees/jists.git
$ cd jists
$ bundle install
$ rake db:create && rake db:migrate
```

Choose a directory to store your jists:

```ruby
# config/development.rb

config.repo_path = "#{Rails.root}/tmp/jists/"
unless File.directory? config.repo_path
  Dir.mkdir(config.repo_path, 0755)
end
```

You'll probably want your production directory elsewhere and backed up.