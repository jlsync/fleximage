# Load the environment
ENV["RAILS_ENV"] = "test"
require File.expand_path("../rails_root/config/environment.rb",  __FILE__) 

# Load the testing framework
require 'rails/test_help'
silence_warnings { RAILS_ENV = ENV['RAILS_ENV'] }
 
# Run the migrations
ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate")
 
# Setup the fixtures path
Test::Unit::TestCase.fixture_path = File.dirname(__FILE__) + "/fixtures/"
$LOAD_PATH.unshift(Test::Unit::TestCase.fixture_path)
 
require File.dirname(__FILE__) + '/mock_file'
require File.dirname(__FILE__) + '/s3_stubs'
require 'open-uri'

unless Magick::QuantumDepth == 16
  puts "**** WARNING ****"
  puts "* Tests expect a ImageMagick bit depth of 16, you have Magick::QuantumDepth == #{Magick::QuantumDepth}"
  puts "* Color checking tests will likely fail"
end

class Test::Unit::TestCase #:nodoc:
  def create_fixtures(*table_names)
    if block_given?
      Fixtures.create_fixtures(Test::Unit::TestCase.fixture_path, table_names) { yield }
    else
      Fixtures.create_fixtures(Test::Unit::TestCase.fixture_path, table_names)
    end
  end
 
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
  
  def files(name)
    case name
    when :photo
      MockFile.new("#{Rails.root}/../fixtures/photo.jpg")
      
    when :not_a_photo
      MockFile.new("#{Rails.root}/../fixtures/not_a_photo.xml")
    
    when :web_photo
      'http://www.google.com/intl/en_ALL/images/logo.gif'
    
    when :cmyk
      MockFile.new("#{Rails.root}/../fixtures/cmyk.jpg")
    
    when :i100x100
      MockFile.new("#{Rails.root}/../fixtures/100x100.jpg")
      
    when :i1x100
      MockFile.new("#{Rails.root}/../fixtures/1x100.jpg")
      
    when :i100x1
      MockFile.new("#{Rails.root}/../fixtures/100x1.jpg")
      
    when :i1x1
      MockFile.new("#{Rails.root}/../fixtures/1x1.jpg")
    
    end
  end
  
  def color_at(image, coords)
    image.load_image.pixel_color(*coords)
  end
  
  def to_color(rgb)
    Magick::Pixel.new(*rgb)
  end
  
  def assert_color(expected, coords, image)
    coords    = coords.split('x').collect(&:to_i)
    expected  = to_color(expected)
    actual    = color_at(image, coords)
    
    assert_equal(expected, actual, "Wrong color at (#{coords.join(',')}).  Expected #{expected}, Got #{actual}")
  end
end
