#!/usr/bin/env ruby

require 'net/http'
require 'json'
require 'lost'
require 'filecache'

# Find current location and cache it, to save waking up the Mac location services too often

LOCATION_CACHE_EXPIRY = 1800 # 30mins
cache = FileCache.new( 'clipper-bar', '/tmp', LOCATION_CACHE_EXPIRY, 2 )
location = cache.get(:location)
if location.nil?
    location = Lost.current_position
    cache.set(:location, location)
end


# API docs at http://content.tfl.gov.uk/tfl-live-bus-river-bus-arrivals-api-documentation-v16.pdf
#
# Following list of returned fields must be expressed in the order they appear
# in the API docs.  The API always returns values in that order, and we
# use this list to turn the returned values into hash values

return_list = %w[
    StopPointName
    LineName
    DestinationName
    EstimatedTime
    ExpireTime
]

SEARCH_RADIUS = 500 # metres to look for stops within

# Build the API call:

url = "http://countdown.api.tfl.gov.uk/interfaces/ura/instant_V1?" +
     "ReturnList=#{return_list.join(',')}&" +
     "Circle=#{location.join(',')},#{SEARCH_RADIUS}&" +
     "StopPointType=SLRS"

uri = URI(url)
res = Net::HTTP.get(uri)

lines = res.split("\n")

lines.shift # Ignore first line of result, the "URA" header in the docs

results = []
stop_points = {}

lines.each do |l|

    # Each line is json-ish enough that we can do this.
    r = JSON.parse(l)

    # Ignore first column of result (it's a 'response type' which is
    # always 1 in the results of this call)
    r.shift

    # "Hashify" the result by zipping (interleaving) the return_list array 
    # and the results array together, then turning that array into a hash.
    boat = Hash[*return_list.zip(r).flatten]

    # List the stop point name in the hash
    stop_points[ boat['StopPointName'] ] = 1

    # Calculate the time between now and the EstimatedTime
    boat_time = Time.at( boat['EstimatedTime'].to_i / 1000 )
    boat['Delta'] = ((boat_time - Time.now) / 60).ceil

    results.push( boat )

end

if results.count == 0
    puts "⛵️ No boats yet"
    exit 0
end

if stop_points.length == 1
    puts "⛵️ #{stop_points.keys.first}"
else
    puts "⛵️ Multiple stops nearby"
end

puts '---'

results.each do |r|
    puts "#{r['Delta']} Mins from #{r['StopPointName']}: #{r['LineName']} to #{r['DestinationName']}"
end

