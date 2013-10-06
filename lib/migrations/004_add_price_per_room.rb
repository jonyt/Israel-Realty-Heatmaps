Sequel.migration do
  change do
    alter_table :listings do
        add_column :price_per_room, Float
    end        
  end
end

