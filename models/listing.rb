require 'sequel'

class Listing < Sequel::Model
  plugin :timestamps, :update_on_create => true	
  
  def address_for_geocoding
    self.address.split(/\s*-\s*/, 2).reverse.join(', ')
  end
end

