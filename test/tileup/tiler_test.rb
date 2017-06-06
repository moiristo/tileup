require 'test_helper'

class TilerTest < Minitest::Test

  def test_it_forces_a_min_zoom_level
    assert_nil create_tiler('map.jpg', auto_zoom_level: -1).options.auto_zoom_level
  end

  def test_it_forces_a_max_zoom_level
    assert_equal 20, create_tiler('map.jpg', auto_zoom_level: 21).options.auto_zoom_level
  end

  def test_it_sets_the_file_extension
    assert_equal 'jpg', create_tiler('map.jpg').extension
  end

  def test_it_makes_tiles
    processors.each do |processor|
      tiles = create_tiler('map.jpg', processor: processor).make_tiles!

      assert tiles.any?, "no tiles found for #{processor}"
      assert tiles.first[File.join(TEST_ROOT, 'out')].any?
    end
  end

  def test_it_makes_tiles_for_zoom_levels
    processors.each do |processor|
      tiles = create_tiler('map.jpg', auto_zoom_level: 2, processor: processor).make_tiles!

      assert tiles.any?, "no tiles found for #{processor}"
      assert tiles[0][File.join(TEST_ROOT, 'out/2')].any?
      assert tiles[1][File.join(TEST_ROOT, 'out/1')].any?
    end
  end
  
  def test_it_generates_base_images
    processors.each do |processor|
      tiler = create_tiler('map.jpg', auto_zoom_level: 4, processor: processor)
      base_images = tiler.build_base_images
      
      assert_equal 4, base_images.size
      base_images.each_with_index do |base_image, index|
        scale = (1.to_f / 2 ** index)
        assert_equal (998 * scale).ceil, tiler.image_processor.width(base_image[:image])
        assert_equal (670 * scale).ceil, tiler.image_processor.height(base_image[:image])
      end
    end
  end
  
  def test_it_extends_crops
    processors.each do |processor|
      tiler = create_tiler('map.jpg', processor: processor)
      tiles = tiler.make_tiles!

      tiles.first[File.join(TEST_ROOT, 'out')].each do |tile_path|
        tile = tiler.image_processor.open(tile_path)
        assert_equal 256, tiler.image_processor.width(tile)
        assert_equal 256, tiler.image_processor.height(tile)
      end
    end    
  end  

  def test_it_ensures_tile_dimensions_are_ints
    options = create_tiler('map.jpg', tile_width: '128', tile_height: '128').options
    assert_equal [128, 128], [options.tile_width, options.tile_height]
  end

  def test_it_determines_the_recommended_auto_zoom_level
    tiler = create_tiler('map.jpg')
    assert_equal 2, tiler.recommended_auto_zoom_level

    tiler.options[:tile_width] = 64
    tiler.options[:tile_height] = 64
    assert_equal 4, tiler.recommended_auto_zoom_level

    tiler.options[:tile_width] = 256
    tiler.options[:tile_height] = 64
    assert_equal 2, tiler.recommended_auto_zoom_level

    tiler.options[:tile_width] = 64
    tiler.options[:tile_height] = 256
    assert_equal 2, tiler.recommended_auto_zoom_level
  end

  def test_it_sets_the_recommended_auto_zoom_level
    tiler = create_tiler('map.jpg', auto_zoom_level: 'auto')
    assert_equal 2, tiler.options.auto_zoom_level
  end

private

  def processors
    @processors ||= %w(rmagick mini_magick)
  end

  def create_tiler fixture_filename, options = {}
    TileUp::Tiler.new(File.join(TEST_ROOT, "files/#{fixture_filename}"), { output_dir: File.join(TEST_ROOT, 'out'), logger: 'none' }.merge(options))
  end

end
