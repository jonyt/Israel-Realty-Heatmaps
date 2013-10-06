require 'sequel'

class CrawlArg < Sequel::Model
  plugin :timestamps, :update_on_create => true	
  
  def url(num_page)
    "http://www.yad2.co.il/Nadlan/rent.php?#{self.search_params}&Neighborhood=&HomeTypeID=&fromRooms=&untilRooms=&fromPrice=&untilPrice=&PriceType=1&FromFloor=&ToFloor=&EnterDate=&Info=&Page=#{num_page}"
  end
  
  def each
    1.upto(self.max_page) do |num_page|
     yield url(num_page)   
    end
  end
  
end

