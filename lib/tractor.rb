# -*- mode: ruby; coding: utf-8 -*-

require 'optparse'
require 'fileutils'
require 'erb'

class Shlauncher_Tractor
  VERSION = "0.0.6"

  include FileUtils::Verbose
  class RakeNotFound < StandardError; end

  def initialize( argv )
    @argv        = argv
    @launcher    = nil
    @email       = nil
    @author      = nil
    @description = nil
    @rake        = _init_rake
  end
  attr_reader :launcher, :email, :author, :description, :rake

  def run
    @launcher = parse_args
    if ( File.exist?( launcher_dir ) )
      puts "'#{launcher}' directory already existed."
    else
      deploy_template
      rewrite_template
      if ( !darwin? )
        puts <<EOD

PLEASE BE CAREFUL with bin/#{launcher} shebang line.
Put the fullpath of rake there.

EOD
      end
    end
  end

  def launcher_dir
    return File.join( Dir.pwd, launcher )
  end

  def deploy_template
    cp_r( File.expand_path( File.dirname( __FILE__ ) + '/../templates/' ),
          launcher_dir )
    Dir.chdir( launcher_dir ) {
      mkdir( 'script' )
      mv( 'bin/shlauncher', "bin/#{launcher}" )
    }
  end

  def rewrite_template
    Dir.chdir( launcher_dir ) {
      targets = %w( Rakefile ChangeLog README ) + ["bin/#{launcher}"]
      targets.each { |file|
        open( file, 'r+' ) { |f|
          erb = ERB.new( f.read )
          f.rewind
          f.truncate( 0 )
          f.puts erb.result( binding )
        }
        puts "rewrited #{file}"
      }
    }
  end

  def parse_args
    app = File.basename( $0 )
    opt = OptionParser.new { |parser|
      parser.version = VERSION
      parser.banner  =<<EOD
#{app} #{VERSION}

Usage: #{app} LAUNCHER_NAME
EOD
      parser.on( '-e', '--email ADDR' ) { |email|
        @email = email
      }
      parser.on( '-a', '--author NAME' ) { |author|
        @author = author
      }
      parser.on( '-d', '--description DESC' ) { |desc|
        @description = desc
      }
    }

    rest_args = opt.parse!( @argv )
    if ( rest_args.size > 0 )
      return rest_args.first
    else
      puts opt.help
      exit
    end
  end

  def linux?
    RUBY_PLATFORM.match( /linux/i )
  end

  def darwin?
    RUBY_PLATFORM.match( /darwin/i )
  end

  def _init_rake
    if ( darwin? )
      return '/usr/bin/env rake'
    else
      rake = which_rake
      if ( rake )
        return rake
      else
        raise RakeNotFound
      end
    end
  end

  def which_rake
    paths = ENV['PATH'].split( File::PATH_SEPARATOR ).select { |path|
      if ( File.exist?( path ) )
        Dir.chdir( path ) {
          Dir.glob( '*' ).include?( 'rake' )
        }
      end
    }
    if ( paths.size > 0 )
      paths.first + '/rake'
    else
      nil
    end
  end
end
