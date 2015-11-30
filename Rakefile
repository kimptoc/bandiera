#!/usr/bin/env rake

$LOAD_PATH.unshift(File.dirname(__FILE__) + '/lib')
require 'bandiera'

begin
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new

  task default: :spec
  task test: :spec
rescue LoadError
  warn 'Could not load RSpec tasks'
end

namespace :db do
  desc 'Run DB migrations'
  task :migrate do |_cmd, _args|
    Bandiera::Db.migrate
  end

  desc 'Rollback the DB'
  task :rollback do |_cmd, _args|
    Bandiera::Db.rollback
  end

  task :demo_reset do |_cmd, _args|
    db   = Bandiera::Db.connect
    serv = Bandiera::FeatureService.new(db)

    db[:groups].delete

    serv.add_features([
      {
        group:       'pubserv',
        name:        'show-article-metrics',
        description: 'Show metrics on the article pages?',
        active:      true
      },
      {
        group:       'pubserv',
        name:        'show-new-search',
        description: 'Show the new search feature?',
        active:      true,
        percentage:  50
      },
      {
        group:       'pubserv',
        name:        'show-reorganised-homepage',
        description: 'Show the new homepage layout?',
        active:      true,
        user_groups: { list: ['editor'], regex: '' }
      }
    ])
  end
end
