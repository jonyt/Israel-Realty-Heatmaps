Sequel.migration do
  change do

    create_table(:geo_requests) do
      primary_key :id
      Integer :num_requests, :null => false
      DateTime :created_at, :null => false
      DateTime :updated_at, :null => false      
    end   
        
  end

end

