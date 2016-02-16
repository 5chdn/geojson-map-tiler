#!/usr/bin/env ruby

# disable mkmf logs
module MakeMakefile::Logging
  @logfile = File::NULL
end

module Tiler
  class GeoJson

    ################################################################################
    # Web Mercator Auxiliary Sphere tiling scheme (WKID 102100)                    #
    # Coordinate system: WGS 1984 Web Mercator (Auxiliary Sphere)                  #
    # Units of measure: meters                                                     #
    # Spatial reference: WKID 102100, EPSG 3857                                    #
    # Map DPI: 96                                                                  #
    # Tile size of map cache: 256 pixels by 256 pixels                             #
    ################################################################################

    def initialize options={}
      # EPSG 3857 pseudo mercator bounds, y axis inverted
      @x_0 = -20037507.0671618
      @y_0 = 20037507.0671618

      # total equator / meridian extent
      @x_equator = @x_0 * -2
      @y_equator = @y_0 * -2

      # null init values
      @debug = false
      @tiles_path_base = nil
      @db = nil
      @query = nil
    end

    def debug _debug
      # enable / disable verbose output
      @debug = _debug
    end

    def set_basedir _basedir
      # full absolute path to the base directory where tiles should be written to
      @tiles_path_base = _basedir
    end

    def setup_db _db, _query
      # database connection in ogr2ogr style
      @db = _db

      # database query in plain sql
      @query = _query
    end

    def setup_complete?
      gdal = find_executable 'ogr2ogr'

      if @tiles_path_base.nil? or @db.nil? or @query.nil?

        # missing configuration
        puts "Setup incomplete!" if @debug
        return false
      elsif gdal.nil?
        puts "GDAL missing!" if @debug
        return false
      else
        return true
      end
    end

    def write_tiles _zoom_factor, _x_low = nil, _x_high = nil, _y_low = nil, _y_high = nil

      return if not setup_complete?

      puts "Starting zoom level #{_zoom_factor} ..." if @debug

      x_num = 2 ** _zoom_factor
      y_num = 2 ** _zoom_factor

      _x_low = 0 if _x_low.nil?
      _y_low = 0 if _y_low.nil?
      _x_high = x_num - 1 if _x_high.nil?
      _y_high = y_num - 1 if _y_high.nil?

      x_tile_size = @x_equator / x_num
      y_tile_size = @y_equator / y_num

      (_x_low.._x_high).each do |x|

        tiles_path_zoom_x = "#{@tiles_path_base}/#{_zoom_factor}/#{x}"
        FileUtils::mkdir_p tiles_path_zoom_x

        (_y_low.._y_high).each do |y|

          tiles_file_y = "#{tiles_path_zoom_x}/#{y}.json"

          x_min = @x_0 + x * x_tile_size
          y_min = @y_0 + y * y_tile_size

          x_max = x_min + x_tile_size
          y_max = y_min + y_tile_size

          puts "Writing #{tiles_file_y} ..." if @debug

          ogr = "ogr2ogr -progress -overwrite -skipfailures -f GeoJSON -clipsrc #{x_min} #{y_min} #{x_max} #{y_max} -t_srs EPSG:4326 #{tiles_file_y} #{@db} -sql #{@query}"
          puts ogr if @debug

          system ogr

        end
      end
    end
  end
end
