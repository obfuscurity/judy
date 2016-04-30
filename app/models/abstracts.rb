
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

  def self.fetch_all_abstracts_and_scores(args=nil)
    @abstracts = Abstract.select('abstracts.*'.lit, 'speakers.full_name AS speaker'.lit, :speakers__email, 'events.name AS event_name'.lit).distinct.
      from(:abstracts, :speakers, :events).
      where(:abstracts__speaker_id => :speakers__id).
      where(:abstracts__event_id => :events__id).
      order(:abstracts__id).all
    @scores = Score.all
    @abstracts.each do |abstract|
      abstract.values[:scores] = [] if abstract.values[:scores].nil?
      abstract.values[:total_score] = 0
      @scores.each do |score|
        if score.abstract_id == abstract.id
          abstract.values[:scores] << { :judge => score.judge, :count => score.count, :comment => score.comment }
          abstract.values[:total_score] += score.count
        end
      end
      abstract.values[:mean_score] = abstract.values[:scores].map {|score| score[:count]}.mean
      abstract.values[:median_score] = abstract.values[:scores].map {|score| score[:count]}.median
      mode_scores = abstract.values[:scores].map {|score| score[:count]}.modes
      abstract.values[:mode_score] = mode_scores.count > 1 ? nil : mode_scores.first
      if args[:judge]
        abstract.values[:my_score] = Score.filter(:judge => args[:judge], :abstract_id => abstract.id).first.count
      end
    end
    if args[:sort].eql?('asc')
      return @sorted_abstracts = @abstracts.sort {|a,b| (a.values[:my_score] || -1) <=> (b.values[:my_score] || -1)}
    elsif args[:sort].eql?('desc')
      return @sorted_abstracts = @abstracts.sort {|a,b| (b.values[:my_score] || -1) <=> (a.values[:my_score] || -1)}
    elsif args[:sort].eql?('mean')
      return @sorted_abstracts = @abstracts.sort {|a,b| (b.values[:mean_score] || -1) <=> (a.values[:mean_score] || -1)}
    elsif args[:sort].eql?('median')
      return @sorted_abstracts = @abstracts.sort {|a,b| (b.values[:median_score] || -1) <=> (a.values[:median_score] || -1)}
    elsif args[:sort].eql?('mode')
      return @sorted_abstracts = @abstracts.sort {|a,b| (b.values[:mode_score] || -1) <=> (a.values[:mode_score] || -1)}
    else
      return @abstracts
    end
  end

  def self.fetch_one_abstract_with_score_by_judge(args)
    @abstract = Abstract.select('abstracts.*'.lit, 'speakers.full_name AS speaker'.lit, :speakers__email, 'events.name AS event_name'.lit).
      from(:abstracts, :speakers, :events).
      where(:abstracts__id => args[:id]).
      where(:abstracts__speaker_id => :speakers__id).
      where(:abstracts__event_id => :events__id).first
    @score = Score.filter(:judge => args[:judge], :abstract_id => args[:id]).first
    @abstract[:score] = @score.count if !@score.nil?
    @abstract[:comment] = @score.comment
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

  def self.type_label(type)
    # here we're associating a Bootstrap label class with each type
    case type
    when 'session'
      return 'primary'
    when 'workshop'
      return 'success'
    when 'lightning'
      return 'warning'
    else
      return 'default'
    end
  end
end
