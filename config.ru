require 'rubygems'
require 'bundler'

Bundler.require

dalli_config = YAML.load(IO.read(File.join('config', 'dalli.yml')))[ENV['RACK_ENV']]

use Rack::Cache,
  :metastore => "memcached://#{dalli_config[:server]}/meta",
  :entitystore => "memcached://#{dalli_config[:server]}/body",
  :default_ttl => dalli_config[:expires_in],
  :allow_reload => true,
  :cache_key => Proc.new { |request|
    if request.env['HTTP_ORIGIN']
      [Rack::Cache::Key.new(request).generate, request.env['HTTP_ORIGIN']].join
    else
      Rack::Cache::Key.new(request).generate
    end
  }

ENV['USER_AGENT'] = 'api-MyAniList-479227514938d8646b93cffa5cb92d4c'

require './app'
run App