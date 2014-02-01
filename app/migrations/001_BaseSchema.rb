
Sequel.migration do
  up do
    create_table(:speakers) do
      primary_key :id
      String      :full_name,     :size => 255, :null => false
      String      :twitter,       :size => 80,  :null => true
      String      :github,        :size => 80,  :null => true
      String      :email,         :size => 255, :null => false
    end

    create_table(:events) do
      primary_key :id
      String      :name
    end

    create_table(:abstracts) do
      primary_key :id
      String      :title,         :size => 255, :null => false
      Text        :body
      foreign_key :speaker_id, :speakers
      foreign_key :event_id,   :events
    end

    create_table(:scores) do
      primary_key :id
      String      :judge,         :size => 80,  :null => false
      Integer     :count,                       :null => false
      foreign_key :abstract_id, :abstracts
    end
  end
  
  down do
    drop_table(:scores, :abstracts, :events, :speakers)
  end
end

