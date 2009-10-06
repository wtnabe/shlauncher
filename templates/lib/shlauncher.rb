# -*- coding: utf-8 -*-

class Shlauncher
  VERSION = '0.0.1'

  LINEBREAK       = /(?:\r\n|[\r\n])/
  IGNORE_PATTERNS = %w( *~ *.bak CVS .svn )

  class SubcomandNotExist < StandardError; end

  def initialize( script_path = nil )
    if ( script_path and File.directory?( script_path ) )
      @script_path = File.expand_path( script_path )
    end
  end

  def run
    if ( ARGV.size == 0 )
      show_info
    else
      argv = ARGV.dup
      task = argv.shift
      case task
      when '-c', '--cat'
        subcmd = argv.shift
        if ( tasks.include?( subcmd ) )
          show_script( subcmd )
        else
          subcommand_not_exist( subcmd )
        end
      when '-h', '--help'
        puts usage
      when '-V', '--version'
        puts version
      else
        if ( tasks.include?( task ) )
          launch_task( task, argv )
        else
          subcommand_not_exist( task )
        end
      end
    end
  end

  def subcommand_not_exist( task )
    raise( SubcomandNotExist,
           "A subcommand `#{task}' does not defined !" )
  end

  def version
    return "#{File.basename( $0 )} ver. #{VERSION}"
  end

  def usage
    version + "\n\n" + <<EOD
Usage: #{File.basename( $0 )} [options] [subcommand [args]]

Options:
   -c  --cat      cat script file
   -h  --help     show this message
   -V  --version  show version number
EOD
  end

  def show_info
    if ( tasks.size == 0 )
      puts usage
      puts "\nNo commands defined."
    else
      show_tasks
    end
    exit
  end

  def show_script( task )
    puts File.open( File.join( script_path, command_path( task ) ) ).read
  end

  def show_tasks
    puts "Defined tasks:"
    maxlen_taskname = 0
    tasks.map { |name|
      if ( name.size > maxlen_taskname )
        maxlen_taskname = name.size
      end
      name
    }.map { |name|
      puts truncate( "#{name.ljust( maxlen_taskname )}  # #{desc( name )}",
                     terminal_width )
    }
  end

  def launch_task( task, args = nil )
    command = File.join( script_path, command_path( task ) )
    if ( File.directory?( command ) )
      tasks( command_path( task ) ).each { |t|
        launch_task( t, args )
      }
    else
      command += " #{args.join(' ')}" if args
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
          taskname = ( path ) ? task( File.join( path, f ) ) : f
          if ( desc( taskname ).size > 0 )
            taskname
          else
            nil
          end
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

# copied from rake

  def terminal_width
    if ENV['RAKE_COLUMNS']
      result = ENV['RAKE_COLUMNS'].to_i
    else
      result = unix? ? dynamic_width : 80
    end
    (result < 10) ? 80 : result
  rescue
    80
  end

  # Calculate the dynamic width of the
  def dynamic_width
    @dynamic_width ||= (dynamic_width_stty.nonzero? || dynamic_width_tput)
  end

  def dynamic_width_stty
    %x{stty size 2>/dev/null}.split[1].to_i
  end

  def dynamic_width_tput
    %x{tput cols 2>/dev/null}.to_i
  end

  def unix?
    RUBY_PLATFORM =~ /(aix|darwin|linux|(net|free|open)bsd|cygwin|solaris|irix|hpux)/i
  end

  def truncate(string, width)
    if string.length <= width
      string
    else
      ( string[0, width-3] || "" ) + "..."
    end
  end
end
