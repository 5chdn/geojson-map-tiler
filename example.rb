#!/usr/bin/env ruby

require 'mkmf'
require 'fileutils'
require './tiler/geojson.rb'

geojson_tiler = Tiler::GeoJson.new

# set up working directory
geojson_tiler.set_basedir "/path/to/my/tiles"

# enable verbose verbose
geojson_tiler.debug true

# setup postgis database connection and sql query to retrieve geodataset
connection = "'PG:host=localhost dbname=distance user=qwertyu password=asdfghj'"
sql_query = "'SELECT id,flags,kmh,geom_way_web_mercator,time FROM streets WHERE time <= 600 ORDER BY time ASC'"
geojson_tiler.setup_db connection, sql_query

# write full tile stack for zoom levels 0, 1, 2 and 3
(0..3).each do |zoom|
  geojson_tiler.write_tiles zoom
end

# write partial tile stack for zoom level 8 in range x: 136..138 and y: 82..84
geojson_tiler.write_tiles 8, 136, 138, 82, 84
