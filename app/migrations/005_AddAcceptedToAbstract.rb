
Sequel.migration do
  up do
    alter_table(:abstracts) do
      add_column :accepted, Integer
    end
  end
end
