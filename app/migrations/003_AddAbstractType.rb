
Sequel.migration do
  up do
    alter_table(:abstracts) do
      add_column :type, String, :null => false
    end
  end

  down do
    alter_table(:abstracts) do
      drop_column :type
    end
  end
end
