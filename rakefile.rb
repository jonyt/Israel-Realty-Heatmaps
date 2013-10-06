namespace :db do
    require 'sequel'
    require_relative 'configuration'

    # Run with -- heroku run rake db:migrate[target,current] 
    task :migrate, [:target, :current] do |task, args|
        Sequel.extension :migration
	    @db = Sequel.connect(Configuration.database_url, :single_threaded=>true)
        migrator = Sequel::Migrator
        
        dir = "#{File.dirname(__FILE__)}/lib/migrations"

        target  = args[:target]  ? args[:target].to_i  : nil
        current = args[:current] ? args[:current].to_i : nil

        puts "Migrate from version #{current} to #{target}"

        migrator.run(@db, dir, :target => target, :current => current)
    end  
end    

task :crawl do
    require_relative 'configuration'    
    Sequel.connect(Configuration.database_url, :single_threaded=>true)
    require_relative 'models/crawl_arg'
    require_relative 'models/listing'
    require_relative 'lib/crawler'    
    require_relative 'lib/parser'
    
    crawler = Crawler.new
    parser = Parser.new
    
    CrawlArg.all.each do |arg|
        counter = 0
        arg.each do |url|            
            fail_count = 0
            listings = nil
            html = ''
            begin
              counter += 1
              puts "Crawling #{url}"
              html = crawler.get(url)   
              listings = parser.parse(html)
              sleep 120 if counter > 20 && counter % 10 == 1             
              fail_count += 1
            end while listings.nil? && fail_count < 10 
            
            puts "Failed on #{url}, ***\n\n#{html}" if fail_count > 9            
            
            listings.each do |listing|
              next if listing[2].nil? || listing[2] == 0
              Listing.create(:address => listing[0], :price => listing[1], :num_rooms => listing[2], :date => listing[3], :price_per_room => listing[1] / listing[2].to_f)
            end
        end
    end
    # Update last crawl time
    # Call geocoding task
end

task :geocode do
    geo_request_limit = 2400
    require_relative 'configuration'    
    Sequel.connect(Configuration.database_url, :single_threaded=>true)
    require_relative 'models/crawl_arg'
    require_relative 'models/listing'
    require_relative 'models/geo_request'
    require 'graticule'
    
    last_geo_request_time = GeoRequest.first
    if last_geo_request_time.nil?
        last_geo_request_time = GeoRequest.create(:num_requests => 0)
    end
    
    if (last_geo_request_time.num_requests > geo_request_limit && (Time.now.to_i - last_geo_request_time.updated_at.to_i) < 24 * 60 * 60)
        puts "Request limit has been exceeded!"
        exit
    end
    
    geocoder = Graticule.service(:google).new ''#"ABQIAAAADQLtsiIkKdfTWed_Wp0JtRTJQa0g3IQ9GZqIMmInSLzwtGDKaBSeV8D1mjYicj5yQ2gY_SfKYtaf2g"    
    already_geocoded = Listing.where('latitude != null').inject({}){|mem, listing| mem.merge!({listing.address => [listing.latitude, listing.longitude]})}                
    
    Listing.where(:latitude => nil).each do |listing|        
      if already_geocoded.has_key?(listing.address)
        puts "Found this address in cache"
        listing.update(:latitude => already_geocoded[listing.address][0], :longitude => already_geocoded[listing.address][1])
      else
        sleep 1
        puts "Requesting location from google"
        begin
          location = geocoder.locate listing.address_for_geocoding
          already_geocoded[listing.address] = [location.coordinates[0], location.coordinates[1]]
          listing.update(:latitude => location.coordinates[0], :longitude => location.coordinates[1])
          last_geo_request_time.update(:num_requests => last_geo_request_time.num_requests + 1)
        rescue => e
          puts "Geocode failed #{e}"
        end               
      end
      
      if geo_request_limit < last_geo_request_time.num_requests
        puts "Request limit has been exceeded!"            
        break
      end
    end    
end
