# -*- mode: ruby; coding: utf-8 -*-

require 'optparse'
require 'fileutils'
require 'erb'

class Shlauncher_Tractor
  VERSION = "0.0.1"

  include FileUtils::Verbose

  def initialize( argv )
    @argv        = argv
    @launcher    = nil
    @email       = nil
    @author      = nil
    @description = nil
  end
  attr_reader :launcher, :email, :author, :description

  def run
    @launcher = parse_args
    if ( File.exist?( launcher_dir ) )
      puts "'#{launcher}' directory already existed."
    else
      deploy_template
      rewrite_template
    end
  end

  def launcher_dir
    return File.join( Dir.pwd, launcher )
  end

  def deploy_template
    cp_r( File.expand_path( File.dirname( __FILE__ ) + '/../template/' ),
          launcher_dir )
    Dir.chdir( launcher_dir ) {
      mkdir( 'script' )
      mv( 'bin/shlauncher', "bin/#{launcher}" )
    }
  end

  def rewrite_template
    Dir.chdir( launcher_dir ) {
      %w( Rakefile Changelog README ).each { |file|
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

end
