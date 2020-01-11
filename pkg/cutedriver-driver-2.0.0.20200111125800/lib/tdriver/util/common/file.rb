############################################################################
## 
## Copyright (C) 2010 Nokia Corporation and/or its subsidiary(-ies). 
## All rights reserved. 
## Contact: Nokia Corporation (testabilitydriver@nokia.com) 
## 
## This file is part of Testability Driver. 
## 
## If you have questions regarding the use of this file, please contact 
## Nokia at testabilitydriver@nokia.com . 
## 
## This library is free software; you can redistribute it and/or 
## modify it under the terms of the GNU Lesser General Public 
## License version 2.1 as published by the Free Software Foundation 
## and appearing in the file LICENSE.LGPL included in the packaging 
## of this file. 
## 
############################################################################

require "fileutils" unless defined?( ::FileUtils )

module MobyUtil

  class FileHelper

    # Function to verify that given folder exists
    # == params
    # path:: String containing path
    # == returns
    def self.folder_exist?( path )

      begin

        Dir.entries( path ).kind_of?( Array )

      rescue

        false

      end

    end

    # Function to load dynamically ruby module(s) from given path
    # == params
    # path:: String containing path
    # == returns
    def self.load_modules( *path )

      # deterimine caller methods working folder
      source_path = File.dirname( MobyUtil::KernelHelper.parse_caller( caller(3).first ).first )
      
      # Compatiblity for Ruby 1.9.2 caller format
      if source_path == "." || source_path[0].to_s == "<" 
        source_path = File.dirname( MobyUtil::KernelHelper.parse_caller( caller(2).first ).first )      
      end
      
      path.each{ | path |

        # expand path if given path is relative path
        path = File.join( source_path, path ) if is_relative_path? path

        # automatically load ruby implementation files if given path is folder
        path = File.join( path, '*.rb' ) if File.directory?( path ) 

        require_files = Dir.glob( MobyUtil::FileHelper.fix_path( path ) )

        raise RuntimeError, "File not found #{ path }" if !File.directory?( path ) && !File.file?( path ) && require_files.empty?

        # load each module found from given folder
        require_files.each { | module_name | 

          # load implementation file
          require module_name

        }

      }

    end

    # Function to fix folder/file path, e.g. remove duplicate back-/slashes
    # == params
    # logger_instance:: Instance of TDriver logger
    # == returns
    # String:: String presentation of fixed path
    def self.fix_path( path )      

      path.check_type( String, "Wrong argument type $1 for file path (expected $2)" )

      # replace back-/slashes to File::SEPARATOR
      path.gsub( /[\\\/]/, File::SEPARATOR ).to_s

    end

    # Private helper function to set tdriver_home directory depending on os. 
    # Known possible issue: javaruby or similar, will not return correctly
    # == params
    # == returns
    # String:: String presentation of TDriver home directory
    def self.tdriver_home

      File.expand_path(
        MobyUtil::FileHelper.fix_path( 
          ENV['TDRIVER_HOME'] || ( MobyUtil::EnvironmentHelper.windows? ? "c:/tdriver" : "/etc/tdriver" ) 
        )
      )

    end

    # Function for expand tdriver specific relative file paths
    # === params
    # file_path:: String containing (file-) path
    # === returns
    # String:: String containing expanded file path
    # === raises
    # TypeError:: Wrong argument type <class> for file path (expected <class>)
    # ArgumentError:: Given path is empty
    def self.is_relative_path?( path )  

      path.check_type( String, "Wrong argument type $1 for file path (expected $2)" )

      #raise ArgumentError.new("Given path is empty") if path.empty?
      path.not_empty( "Filepath must not be empty string" )

      dirname =  File.dirname( path )

      if MobyUtil::EnvironmentHelper.windows?

        # windows
        ( dirname =~ /^[a-z]+:(\\|\/)/i ).nil? && ( dirname[ 0 ].chr =~ /(\\|\/)/ ).nil?    

      else

        # linux
        ( path[ 0 ].chr != '~' ) && ( dirname[ 0 ].chr != File::SEPARATOR )

      end

    end

    # Function for expand tdriver specific relative file paths
    # === params
    # file_path:: String containing (file-) path
    # === returns
    # String:: String containing expanded file path
    # === raises
    def self.expand_path( file_path )

      _file_path = file_path # we don't want to modify original variable

      return _file_path if _file_path.nil? || _file_path.empty?

      _file_path = MobyUtil::FileHelper.fix_path( _file_path )

      File.expand_path( MobyUtil::FileHelper.is_relative_path?( _file_path ) ? File.join( MobyUtil::FileHelper.tdriver_home, _file_path ) : _file_path )

    end

    # Function for retrieve tdriver configuration file content from absolute or tdrive home path
    # If relative path given, assume that file is located in TDriver home folder
    # === params
    # file_path:: String containing the name and path of file
    # === returns
    # String:: File content
    # === raises
    # ParameterFileNotFoundError - if empty parameter or file doesn't exist
    # ParameterFileParseError:: If parsing failes
    def self.get_file( file_path )

      #p __method__, file_path, caller

      #file_path.check_type( String, "wrong argument type $1 for get_file method (expected $2)")

      # raise exception if file name is empty or nil
      raise EmptyFilenameError, "File name is empty or not defined" if file_path.nil? || file_path.to_s.empty?

      # raise exception if file name is file_path variable format other than string
      raise UnexpectedVariableTypeError.new( "Invalid filename format #{ file_path.class } (expected: String)")  if !file_path.kind_of?( String )

      file_path = MobyUtil::FileHelper.expand_path( file_path )

      # raise exception if file not found
      raise FileNotFoundError.new( "File not found: #{ file_path }" ) unless File.exist?( file_path )

      begin
        # read all content of file
        file_content = IO.read( file_path )
      rescue => ex
        # raise exception if error occured during reading the file
        raise IOError.new("Error occured while reading file #{ file_path }\nDescription: #{ ex.message }")
      end

      # return file content
      file_content

    end

    # Function for create (nested) folder path
    # === params
    # path:: String containing path to be created
    # === returns
    # NilClass
    # === raises
    # IOError:: Error occured while creating folder
    def self.mkdir_path( path )

      begin

        current_path = ""

        path.split( File::SEPARATOR ).each{ | folder | 

          if !folder.empty?

            current_path << folder << File::SEPARATOR

            Dir.mkdir( current_path ) unless File.exist?( current_path )

          else

            current_path << File::SEPARATOR

          end  

        } unless File.directory?( path ) && File.exist?( path )

      rescue => exception

        raise IOError.new("Error occured while creating folder #{ current_path } (#{ exception.message })")

      end

      nil

    end

    # Function for copy file(s) to destination folder, folder will be created if it doesn't exist.
    # === params
    # source:: Array or String containing source filename(s)
    # destination:: String containing of destination folder
    # args:: String containing arguments used for copying
    # file:: String target filename, used to rename source filename on destination
    # === returns
    # NilClass
    # === raises
    # IOError:: Error occured while creating folder
    def self.copy_file( source, destination, verbose = false, overwrite = true, create_folders = true, &block )

      source.check_type( String, "Wrong argument type $1 for source file (expected $2)" )
      
      destination.check_type( String, "Wrong argument type $1 for destination file (expected $2)" )

      sources = []

      if File.directory?( source )

        source_folders = source if ( source_folders = MobyUtil::FileHelper.folder_tree( source ) ).empty?

        source_folders.each{ | folder |

          Dir.glob( File.join( folder, "*.*" ) ).each{ | file | 

            sources << [ file, File.join( destination, folder.gsub( source, "" ), "/", File.basename( file ) ) ] 
          }
        }

      else

        if File.basename( source ) =~ /\*/ 
          # retrieve all files when wildcards used
          Dir.glob( File.join( File.dirname( source ), File.basename( source ) ) ).each{ | file | sources << [ file, File.join( destination, File.basename( file ) ) ] }
        else
          # no wildcards
          sources << [ source, destination ]
        end

      end

      sources.each{ | task |

        source, destination = task

        destination_folder = ( destination = MobyUtil::FileHelper.fix_path( destination ) )[ -1 ].chr =~ /[\\\/]/ ? destination : File.dirname( destination )

        # create destination folder if it doesn't exist and create_folders flag is enabled
        MobyUtil::FileHelper.mkdir_path( destination_folder ) if create_folders

        raise RuntimeError.new( "Unable to copy #{ source } to #{ destination } due to source file does not exist" ) unless File.exist?( source )

        ::FileUtils.copy( 

          MobyUtil::FileHelper.fix_path( source ), 
          destination, 
          :verbose => verbose

        ) unless ( !overwrite && File.exist?( destination ) )
      
        # yield given block, can be used eg. changing the target file's access levels etc.
        yield( destination, source, destination_folder ) if block_given?

      }

    end

    # Function for build list of sub-/folder(s) from given source folder
    # === params
    # source:: String containing source folder
    # folders:: Array internal variable, used in recursion, can be used as result value if given variable is empty array.
    # === returns
    # Array list of folder names
    # === raises
    def self.folder_tree( source, folders = [] )

      Dir.glob( source + "/*" ).each{ | folder |
        if File.directory?( folder ); folders << folder; MobyUtil::FileHelper.folder_tree( folder, folders ); end
      }

      folders.uniq.compact

    end

    # enable hooking for performance measurement & debug logging
    TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

  end # FileHelper

end # MobyUtil
