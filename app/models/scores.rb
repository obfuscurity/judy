
class NilClass
  def method_missing(name, *args, &block)
  end
end

class Score < Sequel::Model

  many_to_one :abstracts
  
  plugin :boolean_readers
  plugin :prepared_statements
  plugin :prepared_statements_safe
  plugin :validation_helpers

  def validate
    super
    validates_presence :judge
    validates_presence :count
  end

  def self.upsert(args)
    @score = Score.filter(:judge => args[:judge], :abstract_id => args[:abstract_id]).first
    if @score.nil?
      Score.new(:count => args[:count], :judge => args[:judge], :abstract_id => args[:abstract_id]).save
    else
      @score.update(:count => args[:count]).save
    end
  end

  def self.judge_progress(judge)
    return { :completed => Score.filter(:judge => judge).all.count, :total => Abstract.all.count }
  end
end
