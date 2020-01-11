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

module TDriver

  class ParameterUserAPI

    class << self

      def new
      
        warn_caller "$1:$2 warning: #{ to_s } is static class; unable initialize new instance of it"
      
        nil
      
      end

      # TODO: document me
      def []=( key, value )

        $parameters[ key ] = value

      end

      # TODO: document me
      def []( *args )

        $parameters[ *args ]

      end

      # TODO: document me
      def fetch( *args, &block )

        $parameters.fetch( *args, &block )

      end

      # TODO: document me
      def files

        $parameters.files

      end

      # TODO: document me
      def clear

        $parameters.clear

      end

      # TODO: document me
      def load_xml( filename )

        $parameters.parse_file( filename )

      end

      # TODO: document me
      def reset( *keys )

        $parameters.reset

      end

      # TODO: document me
      def inspect

        $parameters.inspect

      end

      # TODO: document me
      def to_s

        $parameters.to_s

      end

      # TODO: document me
      def keys

        $parameters.keys

      end

      # TODO: document me
      def values

        $parameters.values

      end

      # TODO: document me
      def configured_suts
      
        $parameters.configured_suts
      
      end

    end # self

    TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

  end # ParameterUserAPI

  class ParameterHash < Hash

    # TODO: document me
    def []( key, *default, &block )

      $last_parameter = fetch( key ){ 

        if default.empty?

          raise MobyUtil::ParameterNotFoundError, "Parameter #{ key.inspect } not found" unless block_given?

          # yield with key if block given
          yield key

        else
        
          raise ArgumentError, "Only one default value allowed for parameter (#{ default.join(', ') })" unless default.size == 1
          
          #result = default.first
          
          #result.kind_of?( Hash ) ? convert_hash( result ) : result
          
          convert_hash( default.first )
          
          
        end

      }

    end

    # TODO: document me
    def []=( key, value )

      raise MobyUtil::ParameterNotFoundError, 'Parameter key nil is not valid' unless key

      super key, convert_hash( value ) # value.kind_of?( Hash ) ? convert_hash( value ) : value

    end
    
    # TODO: document me
    def apply_template( name )
        
      recursive_merge!( 
        TDriver::Parameter.templates.fetch( name.to_s ){ 
        
          raise MobyUtil::TemplateNotFoundError, "Template #{ name.inspect } not found"
        
        }
      )
    
    end
    
    # for backwards compatibility
    def kind_of?( klass )
    
      if klass == MobyUtil::ParameterHash
      
        warn_caller '$1:$2 warning: deprecated class MobyUtil::ParameterHash, use TDriver::ParameterHash instead'
      
        true
      
      else
        
        super klass
      
      end
        
    end
    
  private

    # TODO: document me
    def convert_hash( value )
    
      value.kind_of?( Hash ) ? ParameterHash[ value.collect{ | key, value | [ key, value.kind_of?( Hash ) ? convert_hash( value ) : value ] } ] : value

      #value.class == Hash ? ParameterHash[ value.collect{ | key, value | [ key, value.class == Hash ? convert_hash( value ) : value ] } ] : value

    end
    
    TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

  end # ParameterHash

  class Parameter
  
    # singleton and private methods
    class << self

      def new
      
        warn_caller "$1:$2 warning: #{ to_s } is static class; unable initialize new instance of it"
      
        nil
      
      end
      
      # TODO: document me
      def init

        # initialize only once 
        return if defined?( @initalized )

        # retrieve platform name
        @platform = MobyUtil::EnvironmentHelper.platform

        # detect is posix platform
        @is_posix = MobyUtil::EnvironmentHelper.posix?

        # retrieve parameter filenames from command line arguments
        parse_command_line_arguments

        # reset templates and parameters
        reset_hashes
      
        # indicates that class is already initialized - templates and parameters will not reset
        @initialized = true

      end
    
      private

      def parse_command_line_arguments

        # reset command line argument files list
        @command_line_argument_files = [] 

        capture_elements = false

        ARGV.each_with_index do | value, index |
        
          value = value.to_s
        
          case value
          
            when '--tdriver_parameters', '--matti_parameters'

              warn "warning: #{ value } is deprecated, use -tdriver_parameters instead" if value == '--matti_parameters' 
            
              # capture following xml filenames
              capture_elements = true

              # mark element to be removed
              ARGV[ index ] = nil
            
          else

            # process the string if capturing arguments
            if capture_elements

              # stop capturing if is a option (e.g. --version)
              if [ '-' ].include?( value[ 0 ].chr ) 

                capture_elements = false
              
              # add argument to parameters list if meets the regexp and capture_element is true
              elsif /\.xml$/i.match( value )
             
                # expand filename
                value = File.expand_path( value )
              
                # raise exception if given file does not found
                raise MobyUtil::FileNotFoundError, "User defined TDriver parameters file #{ value } does not exist" unless File.exist?( value )

                # add file to command line arguments files
                @command_line_argument_files << value

                # mark element to be removed
                ARGV[ index ] = nil
              
              end # if

            end # else
          
          end # case
        
        end # each_with_index

        # raise exception if "--tdriver_parameters" option found but no filenames defined 
        if capture_elements && @command_line_argument_files.empty? 
        
          raise ArgumentError, 'TDriver parameters command line argument given without a filename'
        
        end
        
        # remove nil elements from array
        ARGV.compact!
        
        # return collected filenames
        @command_line_argument_files
      
      end

      # TODO: document me
      def initialize_class
      
        # initialize only once
        return if defined?( @parameters )
      
        # class variables not used; read below article: 
        # http://www.oreillynet.com/ruby/blog/2007/01/nubygems_dont_use_class_variab_1.html
      
        # parameters container
        @parameters = ParameterHash.new

        # templates container
        @templates = ParameterHash.new

        # platform enum 
        @platform = nil
        
        # determine if platform is type of posix
        @is_posix = nil
        
        # list of loaded SUT's
        @sut_list = []

        # list of loaded parameter filenames
        @parameter_files = []

        # list of loaded template filenames
        @template_files = []
        
        # files defined in command line arguments
        @command_line_argument_files = [] 

        # templates cache
        @cache = {}

      end

      # TODO: document me
      def load_default_parameters
      
        # collect all templates
        Dir.glob( MobyUtil::FileHelper.expand_path( 'defaults/*.xml' ) ).each { | filename | 

          file_content = load_file( filename )
          
          MobyUtil::XML.parse_string( file_content ).xpath( '*' ).each{ | element |

            # merge new hash to parameters hash
            @parameters.recursive_merge!( 
            
              # parse element and convert it to hash 
              process_element( element )
              
            )
            
          }
          
          # add file to loaded parameter files list
          @parameter_files << filename

        }
      
      end

      # TODO: document me
      def load_file( filename )

        filename = MobyUtil::FileHelper.expand_path( filename )

        begin

          MobyUtil::FileHelper.get_file( filename )

        rescue MobyUtil::EmptyFilenameError

          raise $!, 'Unable to load parameters XML file due to filename is empty or nil'

        rescue MobyUtil::FileNotFoundError

          raise

        rescue IOError

          raise $!, "Error occured while loading xml file. Reason: #{ $!.message }"

        rescue

          raise MobyUtil::ParameterFileParseError, "Error occured while parsing parameters xml file #{ filename }\nDescription: #{ $!.message }"

        end

      end
      
      # TODO: document me
      def process_element( xml )
                
        # calculate xml hash
        xml_hash = xml.to_s.hash
        
        return @cache[ xml_hash ] if @cache.has_key?( xml_hash )

        # default results 
        results = ParameterHash.new

        # go through each element in xml
        xml.xpath( "*" ).each{ | element |

          # retrieve element attributes as hash
          attributes = element.attributes

          # default value
          value = attributes[ 'value' ]

          # generic posix value - overwrites attribute["value"] if found
          value = attributes[ 'posix' ] unless attributes[ 'posix' ].nil? if @is_posix

          # platform specific value - overwrites existing value
          value = attributes[ @platform.to_s ] unless attributes[ @platform.to_s ].nil?

          # retrieve name attribute
          name = attributes[ 'name' ]

          case element.name

            when 'include'

              directory = MobyUtil::FileHelper.expand_path( attributes[ 'directory' ] )

              files_pattern = Regexp.new( attributes[ 'files' ] )

=begin
              pattern_flags = attributes[ 'flags' ].to_s.each_char.inject( 0 ){ | flags, char | 

                case char

                  when /m/i

                    flags += Regexp::MULTILINE

                  when /i/i

                    flags += Regexp::IGNORECASE

                  when /x/i

                    flags += Regexp::EXTENDED

                else

                  raise ArgumentError, "Invalid regular expression pattern flag #{ char.inspect } (expected: 'm', 'i' or 'x')"

                end

              }
=end
  
              value = ParameterHash.new

              included_files = []

              # iterate each found file from given directory
              Dir.glob( File.join( directory, '*' ) ).each do | file |

                # and merge content of the file if filename matches with given files pattern
                if File.basename( file ) =~ files_pattern

                  value.merge!( process_file( file, false ) ) 

                  included_files << file

                end

              end

              # merge included values to results
              results.merge!( value )

              # store included files to :included_files value
              name = "included_files"

              # append to :included files value
              value = ( results[ name.to_sym, [] ].concat( included_files ) ).compact.uniq

            when 'keymap'

              # use element name as parameter name ("keymap")
              name = element.name

              # read xml file from given location if defined - otherwise pass content as is
              if attributes[ 'xml_file' ]

                # merge hash values (value type of hash)
                value = process_file( attributes[ 'xml_file' ] )

              else

                # use element content as value
                value = process_element( element )

              end

              # retrieve environment attribute from xml
              env = attributes[ 'env' ].to_s

              # set environment to 'default' unless defined in xml element
              env = 'default' if env.empty?

              # store keymap as hash
              value = { env.to_sym => value, :all => value, :default_keymap => env.to_sym }
              
            when 'fixture'

              name.not_blank( "No name defined for fixture \"#{ element.to_s }\"", SyntaxError )

               value = { 
               
                 :plugin => attributes[ 'plugin' ].not_blank( "No name defined for fixture with value #{ name }", SyntaxError ),
                  
                 :env => attributes[ 'env' ]
                 
               }
               
            when 'parameter'

              # verify that name attribute is defined
              name.not_blank( "No name defined for parameter with value #{ value }", SyntaxError )

              # return value as is
              #value.not_nil( "No value defined for parameter with name #{ name }", SyntaxError )

              value = '' if value.nil?

            when 'method'

              # verify that name attribute is defined
              name.not_blank( "No name defined for parameter with value #{ value }", SyntaxError )

              # return value as is
              #value.not_nil( "No value defined for parameter with name #{ name }", SyntaxError )

              value = attributes[ 'args' ]

            when 'sut'

              # use id as parameter name
              name = attributes[ 'id' ]

              # verify that name attribute is defined
              name.not_blank( "No name defined for SUT \"#{ element.to_s }\"", SyntaxError )
            
              # add SUT to found sut list
              @sut_list << name unless @sut_list.include?( name ) 
   
              # retrieve names of used templates 
              templates = attributes[ 'template' ]

              # empty value by default
              value = ParameterHash.new

              unless templates.blank?

                # retrieve each defined template
                templates.split( ';' ).each{ | template |
                
                  # merge template with current value hash
                  value.recursive_merge!( 
        
                    # retrieve template          
                    get_template( template )
                  
                  )
                
                }

              end

              # merge sut content with template values
              value.recursive_merge!( process_element( element ) )

          else

            # use element name as parameter name (e.g. fixture, keymap etc)
            name = element.name

            # read xml file from given location if defined - otherwise pass content as is
            if attributes[ 'xml_file' ]

              # merge hash values (value type of hash)
              value = process_file( attributes[ 'xml_file' ] )

            else

              # use element content as value
              value = process_element( element )

            end
            
          end

          # store values to parameters
          results[ name.to_sym ] = value

        }

        # store to cache and return hash as result
        @cache[ xml_hash ] = results

      end
      
      # TODO: document me
      def parse_template( name )
      
        template = @templates[ name ]
        
        unless template.kind_of?( Hash )
        
          result = ParameterHash.new
          
          # retrieve each inherited template
          template[ 'inherits' ].to_s.split(";").each{ | inherited_template |
                
            result.recursive_merge!( 
            
              parse_template( inherited_template )
            
            )
          
          }
          
          # merge template content with inherited templates and store to templates hash table 
          @templates[ name ] = result.recursive_merge!( 
          
            process_element( template ) 
          
          )
   
        else
        
          # template is already parsed, pass template hash as is 
          template
                
        end
      
      end

      # TODO: document me
      def load_templates

        # collect all templates
        Dir.glob( MobyUtil::FileHelper.expand_path( 'templates/*.xml' ) ).each { | filename | 

          unless @template_files.include?( filename )

            # read file content
            file_content = load_file( filename )

            MobyUtil::XML.parse_string( file_content ).root.xpath( 'template' ).each{ | template |

              # store template element to hash
              @templates[ template[ 'name' ] ] = template
              
            }

            # add file to loaded templates files list
            @template_files << filename

          end

        }
        
        # parse templates hash; convert elements to hash
        @templates.each_pair{ | name, template | 
        
          # convert element to hash
          parse_template( name )
        
        }
      
      end

      # TODO: document me
      def get_template( name )
      
        @templates.fetch( name ){ 

          # return empty hash if template not found
          ParameterHash.new

        }
      
      end

      # TODO: document me
      def reset_hashes( options = {} )
        
        # default options
        options.default_values( 
        
          :reset_templates => true,
          :reset_parameters => true,
          
          :load_default_parameters => true,
          :load_user_parameters => true,
          :load_command_line_parameters => true
        
        )
        
        # empty parameters hash        
        if options[ :reset_parameters ] == true

          @parameter_files.clear

          @parameters.clear 

        end

        if options[ :reset_templates ] == true
        
          @template_files.clear
        
          # empty templates hash        
          @templates.clear

          # load parameter templates
          load_templates

        end

        # apply global parameters to root level (e.g. TDriver::Parameter[ :logging_outputter_enabled ])
        @parameters.recursive_merge!( 

          get_template( 'global' ) 

        )

        # load and apply default parameter values
        load_default_parameters if options[ :load_default_parameters ] == true

        # load main parameter configuraion file
        load_parameters_file( 'tdriver_parameters.xml' ) if options[ :load_user_parameters ] == true

        if options[ :load_command_line_parameters ] == true

          @command_line_argument_files.each{ | filename |
          
            load_parameters_file( filename )
          
          }

        end

      end

      # TODO: document me
      def process_file( filename, root = true )

        begin
        
          # load content from file
          file_content = load_file( filename )
        
          # parse file content and retrieve root element
          root_element = MobyUtil::XML.parse_string( file_content ) #.root

          root_element = root_element.root if root == true
        
          # parse root element
          process_element( root_element )

        rescue MobyUtil::FileNotFoundError

          raise $!, "Parameters file #{ MobyUtil::FileHelper.expand_path( filename ) } does not exist"

        rescue

          raise MobyUtil::ParameterFileParseError, "Error occured while parsing parameters XML file #{ filename }. Reason: #{ $!.message } (#{ $!.class })"

        end

      end
      
      def process_string( source )

        begin
                
          # parse file content and retrieve root element
          root_element = MobyUtil::XML.parse_string( source ).root

          # parse root element
          process_element( root_element )

        rescue

          raise MobyUtil::ParameterXmlParseError, "Error occured while parsing parameters XML string. Reason: #{ $!.message } (#{ $!.class })"

        end
      
      end
      
      def load_parameters_file( filename )

        filename = MobyUtil::FileHelper.expand_path( filename )
  
        unless @parameter_files.include?( filename )

          begin

            @parameters.recursive_merge!(

              process_file( filename )

            )

          rescue MobyUtil::FileNotFoundError

            raise $!, "Parameters file #{ filename } does not exist"
          
          end

          # add file to loaded parameter files list
          @parameter_files << filename

        end # unless
      
      end # def
      
    end # self
    
    class << self

      # TODO: document me
      def parse_file( filename, reset_parameters = false )

        # check argument type for filename
        filename.check_type [ String ], 'wrong argument type $1 for filename argument (expected $2)'

        # check argument type for filename
        reset_parameters.check_type [ TrueClass, FalseClass ], 'wrong argument type $1 for reset_parameters boolean argument (expected $2)'

        # reset parameter hash if requested
        @parameters.clear if reset_parameters == true
      
        # load and parse given file
        load_parameters_file( filename )
      
      end
      
      # TODO: document me
      def parse_string( source, merge_hashes = true )
      
        # check argument type for source
        source.check_type [ String ], 'wrong argument type $1 for source XML argument (expected $2)'

        # check argument type for merge_hashes
        merge_hashes.check_type [ TrueClass, FalseClass ], 'wrong argument type $1 for merge_hashes argument (expected $2)'

        # process xml string, returns hash as result
        hash = process_string( source )  

        if merge_hashes
        
          @parameters.recursive_merge!( hash )
        
        else

          @parameters.merge!( hash )
        
        end
      
      end
          
      # TODO: document me
      def clear
      
        @parameter_files.clear
      
        @parameters.clear
      
      end

      # TODO: document me
      def files
      
        # return loaded parameter files list
        @parameter_files
      
      end

      # TODO: document me
      def template_files
      
        # return loaded parameter files list
        @template_files
      
      end

      # TODO: document me
      def has_template?( name )
      
        @templates.has_key?( name.to_s )
      
      end
      
      # TODO: document me
      def apply_template( name )
        
        @parameters.recursive_merge!( 
          @templates.fetch( name.to_s ){           
            raise MobyUtil::TemplateNotFoundError, "Template #{ name.inspect } not found"
          }
        )

      end

      # TODO: document me
      def has_key?( key )
      
        @parameters.has_key?( key )
      
      end

      # TODO: document me
      def has_value?( key )
      
        @parameters.has_value?( key )
      
      end
      
      # TODO: document me
      def keys
      
        @parameters.keys
      
      end

      # TODO: document me
      def values
      
        @parameters.values
      
      end

      # TODO: document me
      def []( key, *default )
      
        @parameters[ key, *default ]
            
      end

      # TODO: document me
      def []=( key, value )
      
        @parameters[ key ] = value
      
      end

      # TODO: document me
      def fetch( key, *default, &block )

        @parameters.__send__( :[], key, *default, &block )

      end

      # TODO: document me
      def if_found( key, &block )

        @parameters.__send__( :if_found, key, &block )

      end

      # TODO: document me
      def delete( key )
      
        @parameters.delete( key )
      
      end
      
      # TODO: document me
      def inspect
      
        @parameters.inspect
      
      end

      # TODO: document me
      def templates
      
        @templates
      
      end

      def parameters

        warn "warning: deprecated method #{ self.name }##{ __method__ }; please use #{ self.name }#hash instead"
      
        hash
        
      end

      def hash
      
        @parameters
        
      end

      # TODO: document me
      def reset

        reset_hashes
            
      end

      # TODO: document me
      def configured_suts
      
        @sut_list
      
      end
    
      # deprecated methods
      def reset_parameters
      
        warn "warning: deprecated method #{ self.name }##{ __method__ }; please use #{ self.name }#reset instead"
      
        reset
      
      end

      # load parameter xml files
      def load_parameters_xml( filename, reset = false )

        warn "warning: deprecated method #{ self.name }##{ __method__ }; please use #{ self.name }#parse_file instead"

        parse_file( filename, reset )

      end

    end
  
    TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

    # initialize parameters class
    initialize_class

  end # Parameter

end

module MobyUtil

  class ParameterHash

    class << self
            
      def new
      
        warn_caller "$1:$2 warning: #{ to_s } is deprecated; use TDriver::ParameterHash instead"
      
        TDriver::ParameterHash.new
      
      end

    end # self
  
  end # ParameterHash

  class Parameter
  
    class << self

      undef :inspect if respond_to?( :inspect )
            
      def new
      
        warn_caller "$1:$2 warning: #{ to_s } is static class; unable initialize new instance of it"
      
        nil
      
      end
        
      def method_missing( id, *args )
          
        warn_caller "$1:$2 warning: deprecated method; use TDriver::Parameter##{ id.to_s } instead of MobyUtil::Parameter##{ id.to_s }"
      
        TDriver::Parameter.__send__( id, *args ) 
            
      end

      # TODO: document me
      def instance
      
        warn_caller "$1:$2 warning: deprecated method #{ self.name }##{ __method__ }; please use #{ self.name } class static methods instead"
        
        TDriver::Parameter
      
      end
    
    end # self
  
  end # Parameter
  
  class ParameterUserAPI
  
    class << self

      undef :inspect if respond_to?( :inspect )

      def new
      
        warn_caller "$1:$2 warning: #{ to_s } is static class; unable initialize new instance of it"
      
        nil
      
      end
    
      def method_missing( id, *args )
              
        warn_caller "$1:$2 warning: deprecated method; use TDriver::ParameterUserAPI##{ id.to_s } instead of MobyUtil::ParameterUserAPI##{ id.to_s }"
      
        TDriver::ParameterUserAPI.__send__( id, *args )
            
      end

      # TODO: document me
      def instance

        warn_caller "$1:$2 warning: deprecated method #{ self.name }##{ __method__ }; please use #{ self.name } class static methods instead"

        TDriver::ParameterUserAPI

      end
    
    end # self
  
  end # ParameterUserAPI

end # MobyUtil

# set global variable pointing to parameter class
$parameters = TDriver::Parameter #MobyUtil::Parameter

# set global variable pointing to parameter API class
$parameters_api = TDriver::ParameterUserAPI
