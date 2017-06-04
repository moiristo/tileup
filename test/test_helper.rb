$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'minitest/autorun'
require 'pry'
require 'tileup'

GEM_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))
TEST_ROOT = File.join(GEM_ROOT, 'test')
