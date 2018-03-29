module TileUp
  class ImageProcessor
    attr_accessor :logger

    def self.build(processor, logger)
      case processor
      when 'mini_magick' then TileUp::ImageProcessors::MiniMagick.new(logger)
      else TileUp::ImageProcessors::RMagick.new(logger)
      end
    end

    def initialize logger
      self.logger = logger
    end

    def open image_filename
      image = open_image(image_filename)
      logger.info "Opened #{image_filename}, #{width(image)} x #{height(image)}"
      image
    rescue => e
      logger.error "Could not open image #{image_filename}: #{e.message}"
      raise e
    end

    def scale image, scale
      logger.verbose "Scale: #{scale}"

      if scale != 1.0
        scale_image(image, scale)
      else
        image
      end
    end

    def crop_and_save image, crop, filename:, extend_crop: false, extend_color: 'none'
      logger.verbose "Crop: x: #{crop[:x]}, y: #{crop[:y]}, w: #{crop[:width]}, h: #{crop[:height]}"
      crop_and_save_image(image, crop, filename: filename, extend_crop: extend_crop, extend_color: extend_color)
    end

    # Interface

    def width image
      raise NotImplementedError
    end

    def height image
      raise NotImplementedError
    end

  private

    def open_image image
      raise NotImplementedError
    end

    def scale_image image
      raise NotImplementedError
    end

    def crop_and_save_image image, crop, filename:, extend_crop: false, extend_color: 'none'
      raise NotImplementedError
    end

    # / Interface
  end
end
