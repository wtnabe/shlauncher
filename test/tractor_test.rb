# -*- coding: utf-8 -*-

require "test/unit"
require File.dirname(__FILE__) + '/../lib/shlauncher/tractor'

class Shlauncher_TractorTest < Test::Unit::TestCase
  def test_Shlauncher_Tractor
    assert( true )
  end

  def setup
    @obj = Shlauncher::Tractor.new( ARGV )
  end
end
