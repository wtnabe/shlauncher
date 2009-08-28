# -*- coding: utf-8 -*-

class Shlauncher
  VERSION = '0.0.1'

  LINEBREAK       = /(?:\r\n|[\r\n])/
  IGNORE_PATTERNS = %w( *~ *.bak CVS .svn )

  def initialize( script_path = nil )
    if ( script_path and File.directory?( script_path ) )
      @script_path = File.expand_path( script_path )
    end
  end

  def launch( task )
    command = File.join( script_path, command_path( task ) )
    if ( File.directory?( command ) )
      tasks( command_path( task ) ).each { |t|
        launch( t )
      }
    else
      system( command )
    end
  end

  def commands_ignored( path = nil )
    base = ( path ) ? File.join( script_path, path ) : script_path

    cmds = []
    IGNORE_PATTERNS.each { |p|
      Dir.chdir( base ) {
        a = Dir.glob( p )
        cmds += a if a.is_a?( Array )
      }
    }
    
    return cmds.uniq
  end

  def tasks( path = nil )
    base = ( path ) ? File.join( script_path, path ) : script_path

    tasks = nil
    Dir.chdir( base ) {
      tasks = Dir.glob( '*' ).map { |f|
        if ( File.directory?( f ) )
          [f, tasks( (( path ) ? File.join( path, f ) : f) )]
        elsif ( File.executable?( f ) and
                !commands_ignored( path ).include?( f ) )
          ( path ) ? task( File.join( path, f ) ) : f
        else
          nil
        end
      }.compact.flatten.sort
    }

    return tasks
  end

  #
  # extract first comment block
  #
  # * read only #-style comment
  # * ignore shebang and local vars defining lines
  # * ignore all after body started ( even #-style comment )
  #
  def desc( task )
    command = command_path( task )
    file = File.join( script_path, command )
    if ( File.exist?( file ) and File.readable?( file ) )
      if ( File.directory?( file ) )
        "exec all tasks in scope `#{task}'"
      else
        body_started = false
        File.open( file ).read.split( LINEBREAK ).map { |line|
          if ( shebang_or_localvar_line?( line ) or empty_line?( line ) or
               body_started )
            nil
          else
            if ( not_comment_line?( line ) )
              body_started = true
              nil
            else
              line.sub( /\A#\s*/, '' )
            end
          end
        }.compact.map { |e|
          ( e.size > 0 ) ? e : nil
        }.compact.join( ", " )
      end
    end
  end

  def command_path( task )
    return task.gsub( /:/, '/' )
  end

  def task( command_path )
    return command_path.gsub( /\//, ':' )
  end

  def script_path
    if ( !@script_path )
      @script_path = File.expand_path( File.dirname( __FILE__ ) + '/../script' )
    end

    return @script_path
  end

  def shebang_or_localvar_line?( line )
    return ( /\A#!/ =~ line or /\A#\s*(-\*-.+:.+-\*-|vim:)/ =~ line )
  end

  def empty_line?( line )
    return ( /[^\s]/ !~ line )
  end

  def not_comment_line?( line )
    return ( /\A\s*#/ !~ line )
  end
end

module Rake
  class Application
    attr_accessor :name
  end
end
