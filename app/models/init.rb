require 'sequel'
require 'json'

db = ENV['DATABASE_URL'] || 'postgres://localhost/judy'
Sequel.connect(db)

$LOAD_PATH.unshift File.dirname(__FILE__)
require 'abstracts'
require 'speakers'
require 'scores'
require 'events'

Sequel.extension :core_extensions

Sequel::Model.plugin :json_serializer
Abstract.plugin :json_serializer
Speaker.plugin :json_serializer
Scores.plugin :json_serializer
Event.plugin :json_serializer
