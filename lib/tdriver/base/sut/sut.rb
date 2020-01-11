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

# abstract class for SUT - no behaviours
module MobyBase

  class SUT

    attr_accessor(
      :id,                  # id of current SUT
      :ui_type,             # ui type
      :ui_version,          # ui version
      :input                # the input method used for interacting with this sut as a symbol, eg. :key or :touch. 
    )

    attr_reader(
      :type,                # type of object ("SUT"), used when applying behaviour
  	  :environment,         # sut environment from parameters file
  	  :test_object_adapter  # test object adapter -- added for now?
  	)

    # Initialize SUT by giving references to the used controller and test object factory
    # == params
    # sut_controller:: Controller object that acts as a facade to the device represented by this SUT
    # test_object_factory:: TestObjectFactory object, a factory for generating creating test objects for this SUT
    # sut_id:: String representing the identification of this SUT - the identification will need to match with group id in parameters xml
    def initialize( sut_controller, test_object_factory, sut_id, test_object_adapter = nil )

      @sut_controller = sut_controller

      # remove this line when possible
      @_sutController = sut_controller

      # remove this line when possible
      @test_object_factory = test_object_factory
      
      # remove this line when possible
      @test_object_adapter = test_object_adapter || TDriver::TestObjectAdapter
      
      @id = sut_id

      # reference to self; easier to access (parent) SUT in shared behaviours applied to test object/sut/application 
      @sut = self
      
      # default values
      @input = :key      
      @type = "sut"

      @object_behaviours = []

      @environment = $parameters[ sut_id ][ :env ]

      @forced_xml = false

    end  

    # Interface to forward command execution to sut specific controller (SutController#execute_command)
    # == params
    # command:: MobyBase::CommandData descendant object defining the command
    # == raises
    # ?:: what ever SutController#execute_command( command ) raises
    # == returns
    # Boolean:: what ever SutController returns 
    def execute_command( command )

      @sut_controller.execute_command( command )

    end

    # TODO: document me
    def inspect

      "#<#{ self.class }:0x#{ ( "%x" % ( object_id.to_i << 1 ) )[ 3 .. -1 ] } @id=#{ @id.inspect } @input=\"#{ @input }\" @type=\"#{ @type }\" @ui_type=\"#{ @ui_type }\" @ui_version=\"#{ @ui_version }\">"

    end

    # enable hooking for performance measurement & debug logging
    TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

  end # SUT
 
end # MobyBase
