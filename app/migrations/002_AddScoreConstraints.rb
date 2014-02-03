
Sequel.migration do
  up do
    alter_table(:scores) do
      add_unique_constraint [:judge, :abstract_id]
    end
  end
end
