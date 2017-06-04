require 'ostruct'
require 'fileutils'
require 'tileup/logger'

module TileUp

  class Tiler

    DEFAULT_OPTIONS = {
      processor: 'rmagick', # or 'mini_magick'
      auto_zoom_levels: nil,
      tile_width: 256,
      tile_height: 256,
      filename_prefix: 'map_tile',
      output_dir: '.',
      logger: 'console',
      extend_incomplete_tiles: true,
      extend_color: 'none',
      verbose: false
    }.freeze

    attr_accessor :image_processor, :image, :options, :extension, :logger

    def initialize(image_filename, options)
      self.options = options = OpenStruct.new(DEFAULT_OPTIONS.merge(options))
      self.logger = TileUp::Logger.build(options.logger, :info, {verbose: options.verbose})
      self.image_processor = TileUp::ImageProcessor.build(options.processor, logger)
      self.image = image_processor.open(image_filename)
      self.extension = image_filename.split(".").last

      %w(tile_width tile_height).each{|dimension| options[dimension] = options[dimension].to_i }

      if options.auto_zoom_levels
        if options.auto_zoom_levels > 20
          logger.warn 'Warning: auto zoom levels hard limited to 20.'
          options.auto_zoom_levels = 20
        elsif options.auto_zoom_levels <= 0
          options.auto_zoom_levels = nil
        end
      end
    end

    def make_tiles!
      if base_images = build_base_images!
        result = base_images.map do |base_image|
          FileUtils.mkdir_p(base_image[:image_path])
          { base_image[:image_path] => make_tiles_for_base_image!(base_image[:image], File.join(base_image[:image_path], options.filename_prefix)) }
        end
        logger.info result
        logger.info 'Done'
        result
      else
        false
      end
    end

    private

    def build_base_images!
      logger.info 'Building base images'

      base_images = base_image_processing_tasks.map do |task|
        {
          image: image_processor.scale(image, task[:scale]),
          image_path: task[:output_dir]
        }
      end

      if base_images
        logger.info "Building base images finished."
        base_images
      else
        logger.info 'Building base images failed.'
        false
      end
    end

    def make_tiles_for_base_image!(base_image, filename_prefix)
      # find image width and height
      # then find out how many tiles we'll get out of
      # the image, then use that for the xy offset in crop.
      num_columns = (image_processor.width(base_image) / options.tile_width.to_f).ceil
      num_rows = (image_processor.height(base_image) / options.tile_height.to_f).ceil

      logger.info "Tiling image into columns: #{num_columns}, rows: #{num_rows}"

      crops_for(num_columns, num_rows).map do |crop|
        filename = "#{filename_prefix}_#{crop[:column]}_#{crop[:row]}.#{extension}"
        is_edge = (crop[:row] == num_rows - 1 || crop[:column] == num_columns - 1)
        image_processor.crop_and_save(base_image, crop, filename: filename, extend_crop: options.extend_incomplete_tiles && is_edge, extend_color: options.extend_color)
        filename
      end
    end

    def base_image_processing_tasks
      if options.auto_zoom_levels.nil?
        [{ output_dir: options.output_dir, scale: 1.0 }]
      else
        current_scale = 1.0
        (1..options.auto_zoom_levels).to_a.reverse.map do |zoom_level|
          task = {
            output_dir: File.join(options.output_dir, zoom_level.to_s),
            scale: current_scale
          }

          current_scale = current_scale / 2
          task
        end
      end
    end

    def crops_for num_columns, num_rows
      crops = []

      x = y = column = row = 0
      while row < num_rows
        crops << {
          row: row,
          column: column,
          x: column * options.tile_width,
          y: row * options.tile_height,
          width: options.tile_width,
          height: options.tile_height
        }

        column += 1
        if column >= num_columns
          column = 0
          row += 1
        end
      end

      crops
    end

  end

end
