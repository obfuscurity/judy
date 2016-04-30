
Sequel.migration do
  up do
    alter_table(:scores) do
      add_column :comment, String
    end
  end
end
