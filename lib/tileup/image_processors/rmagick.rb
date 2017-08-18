module TileUp
  module ImageProcessors
    class RMagick < TileUp::ImageProcessor

      def initialize logger
        require 'rmagick'
        super(logger)
      end

      def width image
        image.columns
      end

      def height image
        image.rows
      end

    private

      def open_image(image_filename)
        ::Magick::Image.read(image_filename).first
      end

      def scale_image image, scale
        image.scale(scale)
      rescue RuntimeError => e
        logger.error "Failed to scale image, are you sure the original image is large enough (#{image.columns} x #{image.rows})?"
        false
      end

      def crop_and_save_image image, crop, filename:, extend_crop: false, extend_color: 'none'
        cropped_image = image.crop(crop[:x], crop[:y], crop[:width], crop[:height], true)

        # unless told to do otherwise, extend tiles in the last row and column
        # if they do not fill an entire tile width and height.
        needs_extension = cropped_image.columns != crop[:width] || cropped_image.rows != crop[:height]

        if extend_crop && needs_extension
          # defaults to white background color, but transparent is probably
          # a better default for our purposes.
          cropped_image.background_color = extend_color
          # fill to width height, start from top left corner.
          cropped_image = cropped_image.extent(crop[:width], crop[:height], 0, 0)
        end

        logger.verbose "Saving tile: #{crop[:column]}, #{crop[:row]}..."
        cropped_image.write(filename)
        logger.verbose "Saving tile: #{crop[:column]}, #{crop[:row]}... saved"

        true
      rescue RuntimeError => e
        logger.error "Failed to crop image: #{e.message}"
        false
      end
    end
  end
end
