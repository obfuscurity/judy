
class NilClass
  def method_missing(name, *args, &block)
  end
end

class Scores < Sequel::Model

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
end
