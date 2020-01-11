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

module MobyUtil

  class Retryable

    # TODO: document me
    def self.sleep_retry_interval( time )

      sleep( time )

    end

    # Function to retry code block for x times if exception raises
    # == params
    # options:: Hash of options 
    #   :tries  Number of tries to perform. Default is 1
    #   :interval  Timeout between retry. Default is 0
    #   :exception  Retry if given type of exception occures. Default is Exception (any error)
    # == returns
    def self.while( options = {}, &block )

      # default options
      options.default_values( :tries => 1, :interval => 0, :exception => Exception )

      attempt = 1


      # number of block arguments
      _block_arity = block.arity 

      if _block_arity > 1

        _block_arity = 2

      elsif _block_arity < 1

        _block_arity = 0

      end

      # last exception
      _exception = nil

      # default
      _arguments = []

      begin

        case _block_arity

          when 1
          arguments = [ attempt ]

          when 2
          arguments = [ attempt, _exception ]

        end

        # yield given block and pass attempt number as parameter
        yield( *arguments )

      rescue *options[ :exception ]

        _exception = $!

        if ( attempt < options[ :tries ] ) && ![ *options[ :unless ] ].include?( $!.class )

          sleep_retry_interval( options[ :interval ] ) if options[ :interval ] > 0

          attempt += 1

          retry

        end

        # raise exception with correct exception backtrace
        raise $!

      end
      
    end

    # Function to retry code block until timeout expires if exception raises 
    # == params
    # options:: Hash of options 
    #   :timeout  Timeout until fail. Default is 0
    #   :interval  Timeout between retry. Default is 0
    #   :exception  Retry if given type of exception occures. Default is Exception (any error)
    # == returns
    def self.until( options = {}, &block )

      # default options
      options.default_values( :timeout => 0, :interval => 0, :exception => Exception )
      
      # store start time
      start_time = Time.now

      # attempt number
      attempt = 0

      # number of block arguments
      _block_arity = block.arity 

      if _block_arity > 1

        _block_arity = 2

      elsif _block_arity < 1

        _block_arity = 0

      end

      # last exception
      _exception = nil

      # default
      _arguments = []

      begin

        case _block_arity

          when 1
          arguments = [ attempt ]

          when 2
          arguments = [ attempt, _exception ]

        end

        # execute block
        yield( *arguments )

      rescue *options[ :exception ]

        _exception = $!

        if (Time.now - start_time) <= options[ :timeout ] && ![ *options[ :unless ] ].include?( $!.class )

          sleep_retry_interval( options[ :interval ] ) if options[ :interval ] > 0

          attempt += 1

          retry

        end

        # raise exception with correct exception backtrace
        raise $!

      end

    end

    # enable hooking for performance measurement & debug logging
    TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

  end # Retryable

end # MobyUtil
