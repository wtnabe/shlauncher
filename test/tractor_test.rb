# -*- coding: utf-8 -*-

require "test/unit"
require File.dirname(__FILE__) + '/../lib/tractor'

class Shlauncher_TractorTest < Test::Unit::TestCase
  def test_Shlauncher_Tractor
    assert( true )
  end

  def setup
    @obj = Shlauncher_Tractor.new( ARGV )
  end

  def test_which_rake
    assert( @obj.which_rake.size > 0 )
  end
end
