module TileUp
  module ImageProcessors
    class MiniMagick < TileUp::ImageProcessor

      require 'mini_magick'

      def width image
        image.width
      end

      def height image
        image.height
      end

    private

      def open_image(image_filename)
        ::MiniMagick::Image.open(image_filename)
      end

      def scale_image image, scale
        open_image(image.path).resize("#{100.0 * scale}%")
      rescue RuntimeError => e
        logger.error "Failed to scale image, are you sure the original image is large enough (#{image.width} x #{image.height})?"
        return false
      end

      def crop_and_save_image image, crop, filename:, extend_crop: false, extend_color: 'none'
        logger.verbose "Saving tile: #{crop[:column]}, #{crop[:row]}..."

        ::MiniMagick::Tool::Convert.new do |convert|
          convert << mpc(image).path
          convert.merge! ['-crop', "#{crop[:width]}x#{crop[:height]}+#{crop[:x]}+#{crop[:y]}"]

          if extend_crop
            convert.merge! ['-background', extend_color]
            convert.merge! ['-extent', "#{crop[:width]}x#{crop[:height]}"]
          end

          convert << filename
        end

        logger.verbose "Saving tile: #{crop[:column]}, #{crop[:row]}... saved"

        true
      rescue RuntimeError => e
        raise e
        logger.error "Failed to crop image: #{e.message}"
        return false
      end

      def mpc image
        @mpcs ||= {}
        @mpcs[image] ||= open_image(image.path).format 'mpc'
      end

    end
  end
end
