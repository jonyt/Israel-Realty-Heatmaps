require 'nokogiri'
require 'time'

class Parser
    def parse(content)
        #doc = Nokogiri::HTML(content, nil, 'Windows-1255')
        doc = Nokogiri::HTML(content)
        table = doc.css('.ads_list')[1]
        return nil if table.nil?
        results = []
        table.css('tr[id^="tr_"]').each do |row| 
            cells = row.css('td')
            address = cells[8].text.strip
            price = cells[10].text.gsub(/[^\d]/, '').to_i
            num_rooms = cells[12].text.to_f
            date = Time.parse(cells[22].text)
            results << [address, price, num_rooms, date] if (price / num_rooms.to_f) > 1000 # Prevent too clever people listing daily rate
        end    
        
        results
    end
end
