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

# TODO: document me  
module TDriver

  # TODO: document me  
  class TestObjectCache

    # TODO: document me  
    def initialize()

      @objects = {}

    end
    
    # TODO: document me  
    def each_object( &block )
    
      @objects.each_value{ | object | yield( object ) }
    
    end
    
    # TODO: document me  
    def objects
    
      @objects
    
    end
        
    # TODO: document me  
    def has_object?( test_object )

      if test_object.kind_of?( Numeric )

        @objects.has_key?( test_object )

      else

        @objects.has_key?( test_object.hash )
      
      end
    
    
    end
    
    # TODO: document me  
    def object_keys
    
      @objects.keys
    
    end
    
    # TODO: document me  
    def object_values
    
      @objects.values
        
    end
    
    # TODO: document me  
    def []( value )
        
      if value.kind_of?( Numeric )

        @objects.fetch( value ){ raise ArgumentError, "Test object (#{ value }) not found from cache" }
      
      else
      
        @objects.fetch( value.hash ){ raise ArgumentError, "Test object (#{ value.hash }) not found from cache" }
      
      end
      
    end
    
    # TODO: document me  
    def add_object( test_object )

      test_object_hash = test_object.hash

      if @objects.has_key?( test_object_hash )
      
        warn( "warning: Test object (#{ test_object_hash }) already exists in cache" )
        
      end
    
      @objects[ test_object_hash ] = test_object
            
      test_object
    
    end

    # TODO: document me  
    def remove_object( test_object )
        
      test_object_hash = test_object.hash
    
      @objects.delete( test_object_hash )
        
      #raise ArgumentError, "Test object (#{ test_object_hash }) not found from cache" unless @objects.has_key?( test_object_hash )
      
      self
    
    end

    # TODO: document me  
    def remove_objects
    
      @objects.clear
    
    end

		# enable hooking for performance measurement & debug logging
		TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

  end # TestObjectCache

end # TDriver
