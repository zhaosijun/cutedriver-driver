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

  class SUTFactory

    # private methods and variables
    class << self

    private

      # TODO: document me
      def initialize_class

        reset

      end

      def mapped_sut?( sut_id )

        $parameters[ :mappings, {} ].has_key?( sut_id.to_sym )

      end

      def get_mapped_sut( sut_id )

        $parameters[ :mappings ][ sut_id.to_sym ].to_sym

      end

      # gets sut from sut-factorys list - if not connected tries to reconnect first
      def get_sut_from_list( id )

        unless @_sut_list[ id ][ :is_connected ]

          @_sut_list[ id ][ :sut ].connect( id )
          @_sut_list[ id ][ :is_connected ] = true

        end

        @_sut_list[ id ][ :sut ]
        
      end

      def sut_exists?( sut_id )

        @_sut_list.has_key?( sut_id )

      end

      def retrieve_sut_id_from_hash( sut_attributes )

        # usability improvement: threat sut_attribute as SUT id if it is type of Symbol or String
        sut_attributes = { :id => sut_attributes.to_sym } if [ String, Symbol ].include?( sut_attributes.class )

        # verify that sut_attributes is type of Hash
        sut_attributes.check_type( [ Hash, Symbol, String ], "Wrong argument type $1 for 'sut_attributes' (expected $2)" )

        # legacy support: support also :Id
        sut_attributes[ :id ] = sut_attributes.delete( :Id ) if sut_attributes.has_key?( :Id )

        sut_attributes.require_key( :id, "Required SUT identification key $1 not defined in 'sut_attributes'" )

        sut_attributes[ :id ].to_sym

      end

      # Finds the sut definition matching the id, either directly or via a mapping
      #
      # === params
      # sut_id:: Symbol defining the id of the sut to search for
      # === returns
      # Symbol:: Either id if it was found in the parameter file or the id of a sut mapped to this id, or nil if no direct or mapped match was found
      # === raises
      # ArgumentError:: The id argument was not a Symbol
      def find_sut_or_mapping( sut_id )

        sut_id.check_type Symbol, 'Wrong argument type $1 for SUT id (expected $2)'

        begin

          # check if direct match exists
          return sut_id if $parameters[ sut_id ]

        rescue MobyUtil::ParameterNotFoundError

          # check if a mapping is defined for the id
          begin        

            # return nil if no mapping exists
            return nil if ( mapped_id = $parameters[ :mappings ][ sut_id ] ).nil?                

            # check if the mapped to sut id exists
            return mapped_id if $parameters[ ( mapped_id = mapped_id.to_sym ) ]

          rescue MobyUtil::ParameterNotFoundError

            # no mappings defined in tdriver_parameters.xml or the mapped to sut was not found
            return nil

          end # check if mapping exists

        end # check if direct match exists

      end # find_sut_or_mapping

    end # self

    # Create/reset hash to store sut ids for all current suts
    def self.reset

      @_sut_list = {}

    end

    # TODO: document me
    def self.disconnect_sut( sut_attributes )

      sut_id = retrieve_sut_id_from_hash( sut_attributes )

      raise RuntimeError, "Unable disconnect SUT due to #{ sut_id.to_s } is not connected" unless sut_exists?( sut_id ) && @_sut_list[ sut_id ][ :is_connected ] 
      
      @_sut_list[ sut_id ][ :sut ].disconnect
      
      @_sut_list[ sut_id ][ :is_connected ] = false

    end 

    def self.reboot_sut( sut_attributes )

      sut_id = retrieve_sut_id_from_hash( sut_attributes )

      raise RuntimeError, "Unable to reboot SUT due to #{ sut_id.to_s } is not connected" unless sut_exists?( sut_id ) && @_sut_list[ sut_id ][ :is_connected ]

      @_sut_list[ sut_id ][ :sut ].reboot

      disconnect_sut( sut_id )

    end

    # TODO: document me
    def self.connected_suts

      @_sut_list

    end

    # Function to create the actual SUT objects based on the 'sut' attribute.
    # === params
    # sut_type:: sut_type - sut type, supportes all types defined by SUTFactory constants
    # id:: id - unique identifier for identifying particular SUT from each other. Is propagated to proper initializers.
    # === returns
    # return:: SUT object
    # raise:: 
    # ArgumentError:: <name> not defined in TDriver parameters XML
    def self.make( sut_attributes )

      sut_id = retrieve_sut_id_from_hash( sut_attributes )

      sut_id = get_mapped_sut( sut_id ) if mapped_sut?( sut_id )

      # if sut is already connected, return existing sut
      return get_sut_from_list( sut_id ) if sut_exists?( sut_id )

      # retrieve sut from parameters
      sut = $parameters[ sut_id, nil ]

      # raise exception if sut was not found
      raise ArgumentError, "#{ sut_id.to_s } not defined in TDriver parameters XML" if sut.nil?
      
      # retrieve sut type from parameters
      sut_type = sut[ :type, nil ]
      
      # raise exception if sut type was not found
      raise RuntimeError, "SUT parameter type not defined for #{ sut_id.to_s } in TDriver parameters/templates XML" if sut_type.nil?

      sut_type_symbol = sut_type.downcase.to_sym

      # retrieve plugin name that implements given sut
      sut_plugin = sut[ :sut_plugin, nil ]

      # retrieve enviroment value from sut, use '*' as default
      sut_env = sut[ :env, '*' ]

      # verify that sut plugin is defined in sut configuration
      raise RuntimeError, "SUT parameter 'sut_plugin' not defined for #{ sut_id.to_s } (#{ sut_type.to_s })" if sut_plugin.nil?
      
      # flag to determine that should exception be raised; allow one retry, then set flag to true if error still occures
      raise_exception = false

      begin

        # verify that sut plugin is registered
        if TDriver::PluginService.plugin_registered?( sut_plugin, :sut )
          
          # create sut object
          created_sut = TDriver::PluginService.call_plugin_method( sut_plugin, :make_sut, sut_id )

        else

          # raise error if sut was not registered
          raise NotImplementedError, "No plugin implementation found for SUT type: #{ sut_type }"

        end

      rescue Exception => exception

        # if sut was not registered, try to load it
        TDriver::PluginService.load_plugin( sut_plugin ) if exception.kind_of?( NotImplementedError )

        if !raise_exception

          raise_exception = true

          retry
          
        else

          # still errors, raise original exception
          raise exception

        end

      end

      # store SUT type to sut object
      created_sut.instance_variable_set( :@ui_type, sut_type )

      # store SUT UI version to sut object
      created_sut.instance_variable_set( :@ui_version, $parameters[ sut_id ][ :version, nil ] )

      # store SUT input type to sut object
      created_sut.instance_variable_set( :@input, $parameters[ sut_id ][ :input_type, nil ] )
      
      # retrieve list of optional extension plugins
      @extension_plugins = $parameters[ sut_id ][ :extension_plugins, "" ].split( ";" )

      # load optional extension plugins
      if @extension_plugins.count > 0

        @extension_plugins.each{ | plugin_name |

          raise_exception = false

          begin

            # verify that extension plugin is registered
            unless TDriver::PluginService.plugin_registered?( plugin_name, :extension )

              # raise error if sut was not registered
              raise NotImplementedError, "Extension plugin not found #{ plugin_name }"

            end

          rescue Exception => exception

            # if sut was not registered, try to load it
            TDriver::PluginService.load_plugin( plugin_name ) if exception.kind_of?( NotImplementedError )

            if !raise_exception

              raise_exception = true

              retry

            else

              # still errors, raise original exception
              raise exception

            end

          end

        }

      end

      # apply sut generic behaviours
      TDriver::BehaviourFactory.apply_behaviour(

        :object        => created_sut,
        :object_type   => [ 'sut'                             ], 
        :sut_type      => [ '*', created_sut.ui_type          ],
        :input_type    => [ '*', created_sut.input.to_s       ],
        :env           => [ '*', *sut_env.to_s.split(";")     ],
        :version       => [ '*', created_sut.ui_version.to_s  ]

      )

      @_sut_list[ sut_id ] = { :sut => created_sut, :is_connected => true }

      created_sut

    end
  
    # enable hooking for performance measurement & debug logging
    TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

    # initialize plugin service 
    initialize_class
  
  end # SUTFactory

end # TDriver

# for backwards compatibility
module MobyBase

  class SUTFactory

    def self.instance
    
      warn_caller '$1:$2 deprecated class MobyBase::SUTFactory, please use static class TDriver::SUTFactory instead'
    
      TDriver::SUTFactory
    
    end

  end # SUTFactory
  
end # MobyBase
