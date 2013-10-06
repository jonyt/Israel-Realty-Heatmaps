Sequel.migration do
  change do

    create_table(:listings) do
      primary_key :id
      Integer :price, :null => false
      Integer :num_rooms, :null => false
      String :address, :null => false
      Float :latitude
      Float :longitude
      DateTime :date
      DateTime :created_at, :null => false
      DateTime :updated_at, :null => false      
    end  
  
    create_table(:crawl_args) do
      primary_key :id
      String :city, :null => false
      Integer :max_page, :null => false
      DateTime :created_at, :null => false
      DateTime :updated_at, :null => false            
    end    
        
  end

end

