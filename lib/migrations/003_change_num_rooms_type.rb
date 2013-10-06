Sequel.migration do
  change do

    alter_table :listings do
        set_column_type :num_rooms, Float
    end
        
  end

end

