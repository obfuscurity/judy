
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

  def self.fetch_all_abstracts_and_scores
    @abstracts = Abstract.select('abstracts.*'.lit, 'speakers.full_name AS speaker'.lit, :speakers__email, 'events.name AS event_name'.lit).distinct.
      from(:abstracts, :speakers, :events).
      where(:abstracts__speaker_id => :speakers__id).
      where(:abstracts__event_id => :events__id).
      order(:abstracts__id).all
    @scores = Score.all
    @abstracts.each do |abstract|
      abstract.values[:scores] = [] if abstract.values[:scores].nil?
      @scores.each do |score|
        if score.abstract_id == abstract.id
          abstract.values[:scores] << { :judge => score.judge, :count => score.count }
        end
      end
    end
    return @abstracts
  end

  def self.fetch_one_abstract_with_score_by_judge(args)
    @abstract = Abstract.select('abstracts.*'.lit, 'speakers.full_name AS speaker'.lit, :speakers__email, 'events.name AS event_name'.lit).
      from(:abstracts, :speakers, :events).
      where(:abstracts__id => args[:id]).
      where(:abstracts__speaker_id => :speakers__id).
      where(:abstracts__event_id => :events__id).first
    @score = Score.filter(:judge => args[:judge], :abstract_id => args[:id]).first
    @abstract[:score] = @score.count if !@score.nil?
    return @abstract
  end

  def self.fetch_all_abstracts_unscored_by_user(user)
    @scores = Score.all
    @unscored_abstracts = []
    Abstract.fetch_all_abstracts_and_scores.each do |abstract|
      # check each abstract for empty :scores or that our user has not already scored it
      @unscored_abstracts << abstract if abstract[:scores].empty? || abstract[:scores].select {|s| s[:judge] == user}.empty?
    end
    return @unscored_abstracts
  end

  def self.fetch_all_abstracts_scored_by_user(user)
    @scores = Score.all
    @scored_abstracts = []
    Abstract.fetch_all_abstracts_and_scores.each do |abstract|
      # check each abstract to see if we've already scored it
      @scored_abstracts << abstract if abstract[:scores].select {|s| s[:judge] == user}.any?
    end
    return @scored_abstracts
  end

  def self.fetch_one_random_unscored_by_user(user)
    @abstracts = Abstract.fetch_all_abstracts_unscored_by_user(user)
    raise Judy::JudgingComplete if @abstracts.empty?
    return @abstracts[rand(@abstracts.count).to_i]
  end
end
