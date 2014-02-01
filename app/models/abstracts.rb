
class NilClass
  def method_missing(name, *args, &block)
  end
end

class Abstract < Sequel::Model

  many_to_one :speakers
  many_to_one :events
  
  plugin :boolean_readers
  plugin :prepared_statements
  plugin :prepared_statements_safe
  plugin :validation_helpers

  def validate
    super
    validates_presence :title
    validates_presence :body
  end

  def self.fetch_abstracts_with_related
    Abstract.select('abstracts.*'.lit, 'speakers.full_name AS speaker'.lit, :speakers__email, 'events.name AS event_name'.lit).
      from(:abstracts, :speakers, :events).
      where(:abstracts__speaker_id => :speakers__id).
      where(:abstracts__event_id => :events__id).
      order(:abstracts__id).all
  end
end
