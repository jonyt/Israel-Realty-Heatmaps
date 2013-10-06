Sequel.migration do
  change do
  	alter_table :crawl_args do
        drop_column :city
        add_column :search_params, String
    end
  end
end
