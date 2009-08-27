# -*- coding: utf-8 -*-

require "test/unit"
require File.dirname(__FILE__) + '/../template/lib/shlauncher'

class ShlauncherTest < Test::Unit::TestCase
  def setup
    @obj = Shlauncher.new( File.dirname( __FILE__ ) + '/script' )
  end

  def test_tasks
    assert( @obj.tasks == %w( example foo foo:bar foo:baz ) )
  end

  def test_commands_ignored
    assert( %w( example~ example.bak ) )
  end

  def test_desc
    assert( @obj.desc( 'example' ) == 'just example, Usage: example' )
  end

  def test_command_path
    assert( @obj.command_path( 'abc' ) == 'abc' )
    assert( @obj.command_path( 'foo:bar' ) == 'foo/bar' )
    assert( @obj.command_path( 'foo/bar' ) == 'foo/bar' )
  end

  def test_task
    assert( @obj.task( 'abc' ) == 'abc' )
    assert( @obj.task( 'foo/bar' ) == 'foo:bar' )
    assert( @obj.task( 'foo//bar' ) == 'foo::bar' )
    assert( @obj.task( 'foo:bar' ) == 'foo:bar' )
  end

  def test_script_path
    assert( @obj.script_path == File.expand_path( File.dirname( __FILE__ ) ) + '/script' )
  end

  def test_shebang_or_localvar_line?
    assert( @obj.shebang_or_localvar_line?( '#! /bin/sh' ) )
    assert( @obj.shebang_or_localvar_line?( '# -*- mode: ruby -*-' ) )
    assert( @obj.shebang_or_localvar_line?( '# -*- coding: utf-8 -*-' ) )
    assert( !@obj.shebang_or_localvar_line?( 'abc' ) )
    assert( !@obj.shebang_or_localvar_line?( '# regular comment' ) )
  end

  def test_empty_line?
    assert( @obj.empty_line?( '' ) )
    assert( @obj.empty_line?( ' ' ) )
    assert( !@obj.empty_line?( '#' ) )
  end

  def test_not_comment_line?
    assert( @obj.not_comment_line?( 'abc' ) )
    assert( !@obj.not_comment_line?( '  #  ' ) )
    assert( !@obj.not_comment_line?( '#   ' ) )
  end
end
