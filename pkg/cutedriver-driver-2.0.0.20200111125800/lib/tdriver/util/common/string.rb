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

# extend Ruby String class functionality
class String

  def true?

    /^true$/i.match( to_s ) != nil
  
  end
  
  def false?
  
    /^false$/i.match( to_s ) != nil
  
  end

  def not_empty( message = "String must not be empty", exception = ArgumentError )

    if empty?
  
      # replace macros
      #message.gsub!( '$1', inspect )
  
      raise exception, message, caller 

    end

    self

  end

  # TODO: document me
  def encode_to_xml

    gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;').gsub( '"', '&quot;' ).gsub( '\'', '&apos;' )

  end

  # Function determines if string is "true" or "false"
  # == params
  # string:: String
  # == returns
  # TrueClass/FalseClass 
  def boolean?

    /^(true|false)$/i.match( self ).kind_of?( MatchData )

  end    

  # Function determines if string is numeric
  # == params
  # string:: Numeric string
  # == returns
  # TrueClass/FalseClass 
  def numeric?

    /^[0-9]+$/.match( self ).kind_of?( MatchData )

  end  

  # Function converts "true" or "false" to boolean 
  # == params
  # string:: String
  # == returns
  # TrueClass/FalseClass 
  def to_boolean( *default )

    if /^(true|false)$/i.match( to_s )
    
      $1.downcase == 'true'
      
    else
        
      # pass default value if string didn't contain boolean
      if default.count > 0
      
        # retrieve first value from array
        default = default.first
        
        # check that argument type is correct
        default.check_type( [ TrueClass, FalseClass ], 'wrong argument type $1 for to_boolean default value argument (expecting $2)') 
        
        # return default value as result
        default
        
      else
      
        # raise exception if no default given
        raise TypeError, "Unable to convert string \"#{ self }\" to boolean (Expected \"true\" or \"false\")", caller

      end

    end

  end    

end

module MobyUtil

  class StringHelper    

    # Function determines if string is "true" or "false"
    # == params
    # string:: String
    # == returns
    # TrueClass/FalseClass 
    def self.boolean?( string )

      # raise exception if argument type other than String
      string.check_type( String, "Wrong argument type $1 (Expected $2)" )

      /^(true|false)$/i.match( string ).kind_of?( MatchData )

    end    

    # Function determines if string is numeric
    # == params
    # string:: Numeric string
    # == returns
    # TrueClass/FalseClass 
    def self.numeric?( string )

      # raise exception if argument type other than String

      string.check_type String, 'Wrong argument type $1 (expected: $2)'

      /^[0-9]+$/.match( string ).kind_of?( MatchData )

    end  

    # Function converts "true" or "false" to boolean 
    # == params
    # string:: String
    # == returns
    # TrueClass/FalseClass 
    def self.to_boolean( string )          

      if MobyUtil::StringHelper::boolean?( string )

        /true/i.match( string ).kind_of?( MatchData )

      else

        raise ArgumentError.new("Invalid value #{ string.inspect } for boolean (expected: \"true\" or \"false\")" )

      end      

    end    

    # enable hooking for performance measurement & debug logging
    TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

  end # StringHelper

end # MobyUtil
