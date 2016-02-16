# geojson-map-tiler
ruby script to create geojson tiles from a postgis database using gdal/ogr

### requires

- `ruby` > 1.9.3, but `ruby` > 2.0.0 recommended
- `gdal/ogr` > 2.0.0, the script utilizes the system command `ogr2ogr`
- `postgresql` > 9.0.0, with `postgis` > 2.0.0 extension installed

### usage

see `example.rb`, setup environment

    #!/usr/bin/env ruby

    require 'mkmf'
    require 'fileutils'
    require './tiler/geojson.rb'

    geojson_tiler = Tiler::GeoJson.new

set up working directory

    geojson_tiler.set_basedir "/path/to/my/tiles"

enable verbose verbose output if desired

    geojson_tiler.debug true

setup postgis database connection and sql query to retrieve geodataset

    connection = "'PG:host=localhost dbname=distance user=qwertyu password=asdfghj'"
    sql_query = "'SELECT id,flags,kmh,geom_way_web_mercator,time FROM streets WHERE time <= 600 ORDER BY time ASC'"
    geojson_tiler.setup_db connection, sql_query

write full tile stack for zoom levels 0, 1, 2 and 3

    (0..3).each do |zoom|
      geojson_tiler.write_tiles zoom
    end

or write partial tile stack for zoom level 8 in range x: 136..138 and y: 82..84

    geojson_tiler.write_tiles 8, 136, 138, 82, 84

syntax is `zoom, xmin, xmax, ymin, ymax`

### credits

quick and dirty by 5chdn (schoedon@uni-potsdam.de)

free and open source released under gplv3.
