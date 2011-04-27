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

module TDriverVerify

  TIMEOUT_CYCLE_SECONDS = 0.1 if !defined?( TIMEOUT_CYCLE_SECONDS )

  @@on_error_verify_block = nil

  def on_error_verify_block( &block )

    raise ArgumentError.new( "No verify block given" ) unless block_given?

    @@on_error_verify_block = block

  end

  def reset_on_error_verify_block

    @@on_error_verify_block = nil

  end

  def execute_on_error_verify_block

    unless @@on_error_verify_block.nil?

      begin

        @@on_error_verify_block.call

      rescue Exception => exception

        raise exception.class.new( "Exception was raised while executing on_error_verify_block. Reason: %s" % [ exception.message ])

      end

    else

      raise ArgumentError.new( "No verify block defined with on_error_verify_block method" )

    end

  end

  # Verifies that the block given to this method evaluates without throwing any exceptions. Verification is synchronized with all connected suts.
  # If this method is called for a sut, synchronization is only done with that sut.
  #
  # === params
  # timeout:: (optional) Integer defining the amount of seconds during which the verification must pass.
  # message:: (optional) A String that is displayed as additional information if the verification fails.
  # === returns
  # nil
  # === raises
  # ArgumentError:: message was not a String or timeout an integer, or no block was given.
  # VerificationError:: The verification failed.
  def verify( timeout = nil, message = nil, &block )
  
    begin

      # determine name of caller method
      verify_caller = caller( 1 ).first.to_s

      # store orignal logging state
      logging_enabled = $logger.enabled

      # disable behaviour logging
      $logger.enabled = false

      # ensure that code block was given
      raise ArgumentError, "No block was given." unless block_given?

      # ensure that timeout is either nil or type of integer
      raise ArgumentError, "wrong argument type #{ timeout.class } for timeout (expected Fixnum or NilClass)" unless [ NilClass, Fixnum ].include?( timeout.class )

      # ensure that message is either nil or type of string
      raise ArgumentError, "Argument message was not a String" unless [ NilClass, String ].include?( message.class ) 

      # convert timeout to integer, nil will be zero
      timeout = get_timeout( timeout )

      # calculate the time when timeout exceeds
      timeout_end_time = Time.now + timeout

      # convert message to string, nil will be empty string
      message = message.to_s

      # add double quotation and trailing whitespace if not empty string
      message = "#{ message.inspect } " if message.length > 0

      # store original timeout value
      original_timeout_value = MobyBase::TestObjectFactory.instance.timeout

      # set the testobject timeout to 0 for the duration of the verify call
      MobyBase::TestObjectFactory.instance.timeout = 0

      loop do
      
        begin
        
          counter = ref_counter

          # execute code block
          yield

          # break loop if no exceptions thrown
          break

        rescue 

          raise if $!.kind_of?( MobyBase::ContinuousVerificationError )

          # refresh and retry unless timeout exceeded
          Kernel::raise $! if Time.new > timeout_end_time
          
          # retry interval
          sleep TIMEOUT_CYCLE_SECONDS

          # refresh suts
          refresh_suts if counter == ref_counter
        
        end # begin
      
      end # do loop
        
    rescue Exception

      # restore logger state
      $logger.enabled = logging_enabled

      # execute on verification error code block
      execute_on_error_verify_block unless @@on_error_verify_block.nil?

      # process the exception
      if $!.kind_of?( MobyBase::ContinuousVerificationError )
      
        raise
            
      else
      
        error_message = "Verification #{ message }at #{ verify_caller } failed as an exception was thrown when the verification block was executed"
        error_message << "#{ MobyUtil::KernelHelper.find_source( verify_caller ) }\nDetails: \n#{ $!.inspect }"
      
      end

      $logger.behaviour "FAIL;Verification #{ message.inspect }failed: #{ $!.to_s }.\n #{ timeout.nil? ? '' : ' using timeout ' + timeout.to_s }.;#{ self.kind_of?( MobyBase::SUT ) ? self.id.to_s + ';sut' : ';' };{};verify;"

      # raise the exception
      raise MobyBase::VerificationError, error_message
       
    ensure

      # restore original test object factory timeout value 
      MobyBase::TestObjectFactory.instance.timeout = original_timeout_value

      # restore logger state
      $logger.enabled = logging_enabled
    
    end

    $logger.behaviour "PASS;Verification #{ message.inspect }at #{ verify_caller } was successful#{ timeout.nil? ? '' : ' using timeout ' + timeout.to_s }.;#{ self.kind_of?( MobyBase::SUT ) ? self.id.to_s + ';sut' : ';' };{};verify;"

    nil
  
  end

  # Verifies that the block given to this method throws an exception while being evaluated. Verification is synchronized with all connected suts.
  # If this method is called for a sut, synchronization is only done with that sut.
  #
  # === params
  # timeout:: (optional) Integer defining the amount of seconds during which the verification must pass.
  # message:: (optional) A String that is displayed as additional information if the verification fails.
  # === returns
  # nil
  # === raises
  # ArgumentError:: message was not a String or timeout an integer, or no block was given.
  # VerificationError:: The verification failed.
  def verify_not( timeout = nil, message = nil, &block )
  
    begin

      # determine name of caller method
      verify_caller = caller( 1 ).first.to_s

      # store orignal logging state
      logging_enabled = $logger.enabled

      # disable behaviour logging
      $logger.enabled = false

      # ensure that code block was given
      raise ArgumentError, "No block was given." unless block_given?

      # ensure that timeout is either nil or type of integer
      raise ArgumentError, "wrong argument type #{ timeout.class } for timeout (expected Fixnum or NilClass)" unless [ NilClass, Fixnum ].include?( timeout.class )

      # ensure that message is either nil or type of string
      raise ArgumentError, "Argument message was not a String" unless [ NilClass, String ].include?( message.class ) 

      # convert timeout to integer, nil will be zero
      timeout = get_timeout( timeout )

      # calculate the time when timeout exceeds
      timeout_end_time = Time.now + timeout

      # convert message to string, nil will be empty string
      message = message.to_s

      # add double quotation and trailing whitespace if not empty string
      message = "#{ message.inspect } " if message.length > 0

      # store original timeout value
      original_timeout_value = MobyBase::TestObjectFactory.instance.timeout

      # set the testobject timeout to 0 for the duration of the verify call
      MobyBase::TestObjectFactory.instance.timeout = 0

      # result container
      result = nil

      loop do
      
        counter = ref_counter

        begin
        
          # execute code block
          result = yield

        rescue

          raise if $!.kind_of?( MobyBase::ContinuousVerificationError )
        
          # break loop if exceptions thrown
          break

        end

        # refresh and retry unless timeout exceeded
        Kernel::raise $! if Time.new > timeout_end_time
        
        # retry interval
        sleep TIMEOUT_CYCLE_SECONDS

        # refresh suts
        refresh_suts if counter == ref_counter
      
      end # do loop
        
    rescue Exception

      # restore logger state
      $logger.enabled = logging_enabled

      # execute on verification error code block
      execute_on_error_verify_block unless @@on_error_verify_block.nil?

      # process the exception
      if $!.kind_of?( MobyBase::ContinuousVerificationError )
      
        raise
    
      elsif $!.kind_of?( MobyBase::VerificationError )
      
        error_message = "Verification #{ message }at #{ verify_caller } failed: #{ MobyUtil::KernelHelper.find_source( verify_caller ) }"
        error_message << "The block did not raise exception. It returned: #{ result.inspect }"
        
      else
      
        error_message = "Verification #{ message }at #{ verify_caller } failed as an exception was thrown when the verification block was executed"
        error_message << "#{ MobyUtil::KernelHelper.find_source( verify_caller ) }\nDetails: \n#{ $!.inspect }"
      
      end

      $logger.behaviour "FAIL;Verification #{ message.inspect }failed: #{ $!.to_s }.\n #{ timeout.nil? ? '' : ' using timeout ' + timeout.to_s }.;#{ self.kind_of?( MobyBase::SUT ) ? self.id.to_s + ';sut' : ';' };{};verify_not;"

      # raise the exception
      raise MobyBase::VerificationError, error_message
       
    ensure

      # restore original test object factory timeout value 
      MobyBase::TestObjectFactory.instance.timeout = original_timeout_value

      # restore logger state
      $logger.enabled = logging_enabled
    
    end

    $logger.behaviour "PASS;Verification #{ message.inspect }at #{ verify_caller } was successful#{ timeout.nil? ? '' : ' using timeout ' + timeout.to_s }.;#{ self.kind_of?( MobyBase::SUT ) ? self.id.to_s + ';sut' : ';' };{};verify_not;"

    nil
  
  end

  # Verifies that the block given to this method evaluates to true. Verification is synchronized with all connected suts.
  # If this method is called for a sut, synchronization is only done with that sut.
  #
  # === params
  # timeout:: (optional) Integer defining the amount of seconds during which the verification must pass.
  # message:: (optional) A String that is displayed as additional information if the verification fails.
  # === returns
  # nil
  # === raises
  # ArgumentError:: message was not a String or timeout an integer, or no block was given.
  # VerificationError:: The verification failed.
  # RuntimeError:: An unexpected error was encountered during verification.
  def verify_true( timeout = nil, message = nil, &block )
  
    begin

      # expected result
      expected_value = true

      # determine name of caller method
      verify_caller = caller( 1 ).first.to_s

      # store orignal logging state
      logging_enabled = $logger.enabled

      # disable behaviour logging
      $logger.enabled = false

      # ensure that code block was given
      raise ArgumentError, "No block was given." unless block_given?

      # ensure that timeout is either nil or type of integer
      raise ArgumentError, "wrong argument type #{ timeout.class } for timeout (expected Fixnum or NilClass)" unless [ NilClass, Fixnum ].include?( timeout.class )

      # ensure that message is either nil or type of string
      raise ArgumentError, "Argument message was not a String" unless [ NilClass, String ].include?( message.class ) 

      # convert timeout to integer, nil will be zero
      timeout = get_timeout( timeout )

      # calculate the time when timeout exceeds
      timeout_end_time = Time.now + timeout

      # convert message to string, nil will be empty string
      message = message.to_s

      # add double quotation and trailing whitespace if not empty string
      message = "#{ message.inspect } " if message.length > 0

      # store original timeout value
      original_timeout_value = MobyBase::TestObjectFactory.instance.timeout

      # set the testobject timeout to 0 for the duration of the verify call
      MobyBase::TestObjectFactory.instance.timeout = 0

      # result container
      result = nil

      loop do
      
        begin
        
          counter = ref_counter

          # execute code block
          result = yield

          # raise exception if result of yield does not equal with expected value 
          raise MobyBase::VerificationError unless result == expected_value

          # break loop if no exceptions thrown
          break

        rescue 

          raise if $!.kind_of?( MobyBase::ContinuousVerificationError )

          # refresh and retry unless timeout exceeded
          Kernel::raise $! if Time.new > timeout_end_time
          
          # retry interval
          sleep TIMEOUT_CYCLE_SECONDS

          # refresh suts
          refresh_suts if counter == ref_counter
        
        end # begin
      
      end # do loop
        
    rescue Exception

      # restore logger state
      $logger.enabled = logging_enabled

      # execute on verification error code block
      execute_on_error_verify_block unless @@on_error_verify_block.nil?

      # process the exception
      if $!.kind_of?( MobyBase::ContinuousVerificationError )
      
        raise
    
      elsif $!.kind_of?( MobyBase::VerificationError )
      
        error_message = "Verification #{ message }at #{ verify_caller } failed: #{ MobyUtil::KernelHelper.find_source( verify_caller ) }"
        error_message << "The block did not return #{ expected_value }. It returned: #{ result.inspect }"
        
      else
      
        error_message = "Verification #{ message }at #{ verify_caller } failed as an exception was thrown when the verification block was executed"
        error_message << "#{ MobyUtil::KernelHelper.find_source( verify_caller ) }\nDetails: \n#{ $!.inspect }"
      
      end

      $logger.behaviour "FAIL;Verification #{ message.inspect }failed: #{ $!.to_s }.\n #{ timeout.nil? ? '' : ' using timeout ' + timeout.to_s }.;#{ self.kind_of?( MobyBase::SUT ) ? self.id.to_s + ';sut' : ';' };{};verify_true;"

      # raise the exception
      raise MobyBase::VerificationError, error_message
       
    ensure

      # restore original test object factory timeout value 
      MobyBase::TestObjectFactory.instance.timeout = original_timeout_value

      # restore logger state
      $logger.enabled = logging_enabled
    
    end

    $logger.behaviour "PASS;Verification #{ message.inspect }at #{ verify_caller } was successful#{ timeout.nil? ? '' : ' using timeout ' + timeout.to_s }.;#{ self.kind_of?( MobyBase::SUT ) ? self.id.to_s + ';sut' : ';' };{};verify_true;"

    nil
  
  end

  # Verifies that the block given to this method evaluates to false. Verification is synchronized with all connected suts.
  # If this method is called for a sut, synchronization is only done with that sut.
  #
  # === params
  # timeout:: (optional) Integer defining the amount of seconds during which the verification must pass.
  # message:: (optional) A String that is displayed as additional information if the verification fails.
  # === returns
  # nil
  # === raises
  # ArgumentError:: message was not a String or timeout an integer, or no block was given.
  # VerificationError:: The verification failed.
  # RuntimeError:: An unexpected error was encountered during verification.
  def verify_false( timeout = nil, message = nil, &block )
  
    begin

      # expected result
      expected_value = false

      # determine name of caller method
      verify_caller = caller( 1 ).first.to_s

      # store orignal logging state
      logging_enabled = $logger.enabled

      # disable behaviour logging
      $logger.enabled = false

      # ensure that code block was given
      raise ArgumentError, "No block was given." unless block_given?

      # ensure that timeout is either nil or type of integer
      raise ArgumentError, "wrong argument type #{ timeout.class } for timeout (expected Fixnum or NilClass)" unless [ NilClass, Fixnum ].include?( timeout.class )

      # ensure that message is either nil or type of string
      raise ArgumentError, "Argument message was not a String" unless [ NilClass, String ].include?( message.class ) 

      # convert timeout to integer, nil will be zero
      timeout = get_timeout( timeout )

      # calculate the time when timeout exceeds
      timeout_end_time = Time.now + timeout

      # convert message to string, nil will be empty string
      message = message.to_s

      # add double quotation and trailing whitespace if not empty string
      message = "#{ message.inspect } " if message.length > 0

      # store original timeout value
      original_timeout_value = MobyBase::TestObjectFactory.instance.timeout

      # set the testobject timeout to 0 for the duration of the verify call
      MobyBase::TestObjectFactory.instance.timeout = 0

      # result container
      result = nil

      loop do
      
        begin
        
          counter = ref_counter

          # execute code block
          result = yield

          # raise exception if result of yield does not equal with expected value 
          raise MobyBase::VerificationError unless result == expected_value

          # break loop if no exceptions thrown
          break

        rescue 

          raise if $!.kind_of?( MobyBase::ContinuousVerificationError )

          # refresh and retry unless timeout exceeded
          Kernel::raise $! if Time.new > timeout_end_time
          
          # retry interval
          sleep TIMEOUT_CYCLE_SECONDS

          # refresh suts
          refresh_suts if counter == ref_counter
        
        end # begin
      
      end # do loop
        
    rescue Exception

      # restore logger state
      $logger.enabled = logging_enabled

      # execute on verification error code block
      execute_on_error_verify_block unless @@on_error_verify_block.nil?

      # process the exception
      if $!.kind_of?( MobyBase::ContinuousVerificationError )
      
        raise
    
      elsif $!.kind_of?( MobyBase::VerificationError )
      
        error_message = "Verification #{ message }at #{ verify_caller } failed: #{ MobyUtil::KernelHelper.find_source( verify_caller ) }"
        error_message << "The block did not return #{ expected_value }. It returned: #{ result.inspect }"
        
      else
      
        error_message = "Verification #{ message }at #{ verify_caller } failed as an exception was thrown when the verification block was executed"
        error_message << "#{ MobyUtil::KernelHelper.find_source( verify_caller ) }\nDetails: \n#{ $!.inspect }"
      
      end

      $logger.behaviour "FAIL;Verification #{ message.inspect }failed: #{ $!.to_s }.\n #{ timeout.nil? ? '' : ' using timeout ' + timeout.to_s }.;#{ self.kind_of?( MobyBase::SUT ) ? self.id.to_s + ';sut' : ';' };{};verify_false;"

      # raise the exception
      raise MobyBase::VerificationError, error_message
       
    ensure

      # restore original test object factory timeout value 
      MobyBase::TestObjectFactory.instance.timeout = original_timeout_value

      # restore logger state
      $logger.enabled = logging_enabled
    
    end

    $logger.behaviour "PASS;Verification #{ message.inspect }at #{ verify_caller } was successful#{ timeout.nil? ? '' : ' using timeout ' + timeout.to_s }.;#{ self.kind_of?( MobyBase::SUT ) ? self.id.to_s + ';sut' : ';' };{};verify_false;"

    nil
  
  end

  # Verifies that the block given to this method evaluates to the expected value. Verification is synchronized with all connected suts.
  # If this method is called for a sut, synchronization is only done with that sut.
  #
  # === params
  # expected:: Expected result value of the block
  # timeout:: (optional) Integer defining the amount of seconds during which the verification must pass.
  # message:: (optional) A String that is displayed as additional information if the verification fails.
  # === returns
  # nil
  # === raises
  # ArgumentError:: message was not a String or timeout an integer, or no block was given.
  # VerificationError:: The verification failed.
  # RuntimeError:: An unexpected error was encountered during verification.
  def verify_equal( expected_value, timeout = nil, message = nil, &block )
  
    begin

      # determine name of caller method
      verify_caller = caller( 1 ).first.to_s

      # store orignal logging state
      logging_enabled = $logger.enabled

      # disable behaviour logging
      $logger.enabled = false

      # ensure that code block was given
      raise ArgumentError, "No block was given." unless block_given?

      # ensure that timeout is either nil or type of integer
      raise ArgumentError, "wrong argument type #{ timeout.class } for timeout (expected Fixnum or NilClass)" unless [ NilClass, Fixnum ].include?( timeout.class )

      # ensure that message is either nil or type of string
      raise ArgumentError, "Argument message was not a String" unless [ NilClass, String ].include?( message.class ) 

      # convert timeout to integer, nil will be zero
      timeout = get_timeout( timeout )

      # calculate the time when timeout exceeds
      timeout_end_time = Time.now + timeout

      # convert message to string, nil will be empty string
      message = message.to_s

      # add double quotation and trailing whitespace if not empty string
      message = "#{ message.inspect } " if message.length > 0

      # store original timeout value
      original_timeout_value = MobyBase::TestObjectFactory.instance.timeout

      # set the testobject timeout to 0 for the duration of the verify call
      MobyBase::TestObjectFactory.instance.timeout = 0

      # result container
      result = nil

      loop do
      
        begin
        
          counter = ref_counter

          # execute code block
          result = yield

          # raise exception if result of yield does not equal with expected value 
          raise MobyBase::VerificationError unless result == expected_value

          # break loop if no exceptions thrown
          break

        rescue 

          raise if $!.kind_of?( MobyBase::ContinuousVerificationError )

          # refresh and retry unless timeout exceeded
          Kernel::raise $! if Time.new > timeout_end_time
          
          # retry interval
          sleep TIMEOUT_CYCLE_SECONDS

          # refresh suts
          refresh_suts if counter == ref_counter
        
        end # begin
      
      end # do loop
        
    rescue Exception

      # restore logger state
      $logger.enabled = logging_enabled

      # execute on verification error code block
      execute_on_error_verify_block unless @@on_error_verify_block.nil?

      # process the exception
      if $!.kind_of?( MobyBase::ContinuousVerificationError )
      
        raise
    
      elsif $!.kind_of?( MobyBase::VerificationError )
      
        error_message = "Verification #{ message }at #{ verify_caller } failed: #{ MobyUtil::KernelHelper.find_source( verify_caller ) }"
        error_message << "The block did not return #{ expected_value }. It returned: #{ result.inspect }"
        
      else
      
        error_message = "Verification #{ message }at #{ verify_caller } failed as an exception was thrown when the verification block was executed"
        error_message << "#{ MobyUtil::KernelHelper.find_source( verify_caller ) }\nDetails: \n#{ $!.inspect }"
      
      end

      $logger.behaviour "FAIL;Verification #{ message.inspect }failed: #{ $!.to_s }.\n #{ timeout.nil? ? '' : ' using timeout ' + timeout.to_s }.;#{ self.kind_of?( MobyBase::SUT ) ? self.id.to_s + ';sut' : ';' };{};verify_equal;"

      # raise the exception
      raise MobyBase::VerificationError, error_message
       
    ensure

      # restore original test object factory timeout value 
      MobyBase::TestObjectFactory.instance.timeout = original_timeout_value

      # restore logger state
      $logger.enabled = logging_enabled
    
    end

    $logger.behaviour "PASS;Verification #{ message.inspect }at #{ verify_caller } was successful#{ timeout.nil? ? '' : ' using timeout ' + timeout.to_s }.;#{ self.kind_of?( MobyBase::SUT ) ? self.id.to_s + ';sut' : ';' };{};verify_equal;"

    nil
  
  end

  # Verifies that the block given to return value matches with expected regular expression pattern. Verification is synchronized with all connected suts.
  # If this method is called for a sut, synchronization is only done with that sut.
  #
  # === params
  # expected:: Regular expression
  # timeout:: (optional) Integer defining the amount of seconds during which the verification must pass.
  # message:: (optional) A String that is displayed as additional information if the verification fails.
  # === returns
  # nil
  # === raises
  # ArgumentError:: message was not a String or timeout an integer, or no block was given.
  # TypeError:: if block result not type of String.
  # VerificationError:: The verification failed.
  # RuntimeError:: An unexpected error was encountered during verification.
  def verify_regexp( expected_value, timeout = nil, message = nil, &block )
  
    begin

      # determine name of caller method
      verify_caller = caller( 1 ).first.to_s

      # store orignal logging state
      logging_enabled = $logger.enabled

      # disable behaviour logging
      $logger.enabled = false

      # ensure that code block was given
      raise ArgumentError, "No block was given." unless block_given?

      # ensure that timeout is either nil or type of integer
      raise ArgumentError, "wrong argument type #{ timeout.class } for timeout (expected Fixnum or NilClass)" unless [ NilClass, Fixnum ].include?( timeout.class )

      # ensure that message is either nil or type of string
      raise ArgumentError, "Argument message was not a String" unless [ NilClass, String ].include?( message.class ) 

      expected_value.check_type Regexp, "wrong argument type $1 for expected result (expected $2)"

      # convert timeout to integer, nil will be zero
      timeout = get_timeout( timeout )

      # calculate the time when timeout exceeds
      timeout_end_time = Time.now + timeout

      # convert message to string, nil will be empty string
      message = message.to_s

      # add double quotation and trailing whitespace if not empty string
      message = "#{ message.inspect } " if message.length > 0

      # store original timeout value
      original_timeout_value = MobyBase::TestObjectFactory.instance.timeout

      # set the testobject timeout to 0 for the duration of the verify call
      MobyBase::TestObjectFactory.instance.timeout = 0

      # result container
      result = nil

      loop do
      
        begin
        
          counter = ref_counter

          # execute code block
          result = yield

          # raise exception if result of yield does not match with expected value regexp 
          raise MobyBase::VerificationError unless result =~ expected_value

          # break loop if no exceptions thrown
          break

        rescue 

          raise if $!.kind_of?( MobyBase::ContinuousVerificationError )

          # refresh and retry unless timeout exceeded
          Kernel::raise $! if Time.new > timeout_end_time
          
          # retry interval
          sleep TIMEOUT_CYCLE_SECONDS

          # refresh suts
          refresh_suts if counter == ref_counter
        
        end # begin
      
      end # do loop
        
    rescue Exception

      # restore logger state
      $logger.enabled = logging_enabled

      # execute on verification error code block
      execute_on_error_verify_block unless @@on_error_verify_block.nil?

      # process the exception
      if $!.kind_of?( MobyBase::ContinuousVerificationError )
      
        raise
    
      elsif $!.kind_of?( MobyBase::VerificationError )
      
        error_message = "Verification #{ message }at #{ verify_caller } failed: #{ MobyUtil::KernelHelper.find_source( verify_caller ) }"
        error_message << "The block did not return #{ expected_value.inspect } pattern. It returned: #{ result.inspect }"
        
      else
      
        error_message = "Verification #{ message }at #{ verify_caller } failed as an exception was thrown when the verification block was executed"
        error_message << "#{ MobyUtil::KernelHelper.find_source( verify_caller ) }\nDetails: \n#{ $!.inspect }"
      
      end

      $logger.behaviour "FAIL;Verification #{ message.inspect }failed: #{ $!.to_s }.\n #{ timeout.nil? ? '' : ' using timeout ' + timeout.to_s }.;#{ self.kind_of?( MobyBase::SUT ) ? self.id.to_s + ';sut' : ';' };{};verify_regexp;"

      # raise the exception
      raise MobyBase::VerificationError, error_message
       
    ensure

      # restore original test object factory timeout value 
      MobyBase::TestObjectFactory.instance.timeout = original_timeout_value

      # restore logger state
      $logger.enabled = logging_enabled
    
    end

    $logger.behaviour "PASS;Verification #{ message.inspect }at #{ verify_caller } was successful#{ timeout.nil? ? '' : ' using timeout ' + timeout.to_s }.;#{ self.kind_of?( MobyBase::SUT ) ? self.id.to_s + ';sut' : ';' };{};verify_regexp;"

    nil
  
  end

  # Verifies that the given signal is emitted.
  #
  # === params
  # timeout:: Integer, defining the amount of seconds during which the verification must pass.
  # signal_name:: String, name of the signal
  # message:: (optional) A String that is displayed as additional information if the verification fails.
  # block:: code to execute while listening signals
  # === returns
  # nil
  # === raises
  # ArgumentError:: message or signal_name was not a String or timeout a non negative Integer
  # VerificationError:: The verification failed.
  def verify_signal( timeout, signal_name, message = nil, &block )

    logging_enabled = $logger.enabled
    verify_caller = caller(1).first.to_s

    begin

      $logger.enabled = false

      Kernel::raise ArgumentError.new("Argument timeout was not a non negative Integer.") unless (timeout.kind_of?(Integer) && timeout >= 0)
      Kernel::raise ArgumentError.new("Argument message was not a non empty String.") unless (message.nil? || (message.kind_of?(String) && !message.empty?))

      # wait for the signal
      begin

        self.wait_for_signal( timeout, signal_name, &block )

      rescue Exception => e

        error_msg = "Verification #{message.nil? ? '' : '"' << message.to_s << '" '}at #{verify_caller} failed:"
        error_msg << MobyUtil::KernelHelper.find_source(verify_caller)
        error_msg << "The signal #{signal_name} was not emitted in #{timeout} seconds."
        error_msg << "\nNested exception:\n" << e.inspect
        Kernel::raise MobyBase::VerificationError.new(error_msg)

      end

    rescue Exception => e

      execute_on_error_verify_block unless @@on_error_verify_block.nil?

      $logger.enabled = logging_enabled
      $logger.log "behaviour" , "FAIL;Verification #{message.nil? ? '' : '\"' << message << '\" '}failed: #{e.to_s} using timeout '#{timeout}.;#{self.kind_of?(MobyBase::SUT) ? self.id.to_s + ';sut' : ';'};{};verify_signal;#{signal_name}"
      Kernel::raise e
    end

    $logger.enabled = logging_enabled
    $logger.log "behaviour" , "PASS;Verification #{message.nil? ? '' : '\"' << message << '\" '}at #{verify_caller} was successful#{timeout.nil? ? '' : ' using timeout ' + timeout.to_s}.;#{self.kind_of?(MobyBase::SUT) ? self.id.to_s + ';sut' : ';'};{};verify_signal;#{signal_name}"
    return nil

  end

=begin

  # old implementation:

  # Verifies that the block given to return value matches with expected regular expression pattern. Verification is synchronized with all connected suts.
  # If this method is called for a sut, synchronization is only done with that sut.
  #
  # === params
  # expected:: Regular expression
  # timeout:: (optional) Integer defining the amount of seconds during which the verification must pass.
  # message:: (optional) A String that is displayed as additional information if the verification fails.
  # === returns
  # nil
  # === raises
  # ArgumentError:: message was not a String or timeout an integer, or no block was given.
  # TypeError:: if block result not type of String.
  # VerificationError:: The verification failed.
  # RuntimeError:: An unexpected error was encountered during verification.
  def verify_regexp( expected, timeout = nil, message = nil, &block )

    logging_enabled = $logger.enabled

    verify_caller = caller( 1 ).first.to_s

    begin

      raise ArgumentError, "No block was given." unless block_given?

      # verify argument types
      timeout.check_type [ Integer, NilClass ], "wrong argument type $1 for timeout (expected $2)"
      message.check_type [ String, NilClass ], "wrong argument type $1 for message (expected $2)"
      expected.check_type Regexp, "wrong argument type $1 for expected result (expected $2)"

      $logger.enabled = false

      #Set the testobject timeout to 0 for the duration of the verify call
      original_sync_timeout = MobyBase::TestObjectFactory.instance.timeout

      MobyBase::TestObjectFactory.instance.timeout = 0

      timeout_time = get_end_time( timeout )

      loop do
      
        counter = ref_counter
        
        # catch errors thrown due to verification results
        begin
        
          # catch errors thrown in the provided block
          begin 
          
            # execute block
            result = yield

          rescue Exception

            raise if $!.kind_of?( MobyBase::ContinuousVerificationError )

            error_msg = "Verification #{ message.nil? ? '' : '"' << message.to_s << '" '}at #{ verify_caller } failed as an exception was thrown when the verification block was executed."

            error_msg << MobyUtil::KernelHelper.find_source( verify_caller )

            error_msg << "\nDetails: \n#{ $!.inspect }"

            raise MobyBase::VerificationError, error_msg

          end

          # verify that result value is type of string
          result.check_type String, "wrong variable type $1 for result (expected $2)" 
          
          # result verification
          unless result =~ expected

            error_msg = "Verification #{ message.nil? ? '' : '"' << message.to_s << '" '}at #{ verify_caller } failed:"
            
            error_msg << MobyUtil::KernelHelper.find_source( verify_caller )
            
            error_msg << "\nThe block did not match with pattern #{ expected.inspect }. It returned: #{ result.inspect }" 

            raise MobyBase::VerificationError, error_msg

          end

          # break loop if no exceptions thrown
          break

        rescue MobyBase::VerificationError

          # refresh and retry unless timeout reached

          raise $! if Time.new > timeout_time

          sleep TIMEOUT_CYCLE_SECONDS

          refresh_suts if counter == ref_counter
          
        rescue MobyBase::ContinuousVerificationError
        
          raise

        rescue TypeError
        
          raise $!
          
        rescue Exception
        
          raise if $!.kind_of?( MobyBase::ContinuousVerificationError )

          # an unexpected error has occurred
          raise RuntimeError, "An unexpected error was encountered during verification:\n#{ $!.inspect }"

        end # begin, catch any VerificationErrors

      end # do

    rescue Exception

      execute_on_error_verify_block unless @@on_error_verify_block.nil?

      raise if $!.kind_of?( MobyBase::ContinuousVerificationError )

      $logger.enabled = logging_enabled
            
      $logger.log "behaviour" , "FAIL;Verification #{message.nil? ? '' : '\"' << message << '\" '}failed:#{ $!.to_s }.\n#{ timeout.nil? ? '' : ' using timeout ' + timeout.to_s }.;#{ self.kind_of?( MobyBase::SUT ) ? "#{ self.id.to_s };sut" : ';' };{};verify_regexp;#{ expected.inspect }" 

      raise $!

    ensure
    
      MobyBase::TestObjectFactory.instance.timeout = original_sync_timeout

      $logger.enabled = logging_enabled
      
    end

    $logger.log "behaviour", "PASS;Verification #{ message.nil? ? '' : '\"' << message << '\" ' }at #{ verify_caller } was successful#{ timeout.nil? ? '' : ' using timeout ' + timeout.to_s}.;#{ self.kind_of?( MobyBase::SUT ) ? "#{ self.id.to_s };sut" : ';'};{};verify_regexp;#{ expected.inspect }"

    nil

  end

  # Verifies that the block given to this method evaluates without throwing any exceptions. Verification is synchronized with all connected suts.
  # If this method is called for a sut, synchronization is only done with that sut.
  #
  # === params
  # timeout:: (optional) Integer defining the amount of seconds during which the verification must pass.
  # message:: (optional) A String that is displayed as additional information if the verification fails.
  # === returns
  # nil
  # === raises
  # ArgumentError:: message was not a String or timeout an integer, or no block was given.
  # VerificationError:: The verification failed.
  def verify( timeout = nil, message = nil, &block )

    logging_enabled = $logger.enabled

    verify_caller = caller(1).first.to_s

    begin

      $logger.enabled = false
      
      Kernel::raise ArgumentError.new("No block was given.") unless block_given?
      Kernel::raise ArgumentError.new("Argument timeout was not an Integer.") unless timeout.nil? or timeout.kind_of?(Integer)
      Kernel::raise ArgumentError.new("Argument message was not a String.") unless message.nil? or message.kind_of?(String)

      #Set the testobject timeout to 0 for the duration of the verify call
      original_sync_timeout = MobyBase::TestObjectFactory.instance.timeout
      MobyBase::TestObjectFactory.instance.timeout = 0

      timeout_time = get_end_time(timeout)
      #TIMEOUT_CYCLE_SECONDS

      loop do

        counter = ref_counter

        begin # catch errors thrown in the provided block

          yield

          # no error => verification ok
          break

        rescue Exception => e

          raise if e.kind_of? MobyBase::ContinuousVerificationError

          source_contents = ""
          error_msg = ""

          if Time.new > timeout_time

            error_msg = "Verification #{message.nil? ? '' : '"' << message.to_s << '" '}at #{verify_caller} failed\n"

            begin

              source_contents = MobyUtil::KernelHelper.find_source(verify_caller)

            rescue Exception
              # failed to load line from file, do nothing
              $logger.enabled = logging_enabled
              $logger.log "behaviour" , "WARNING;Failed to load source line: #{e.backtrace.inspect}.;#{self.kind_of?(MobyBase::SUT) ? self.id.to_s + ';sut' : ';'};{};verify;"
            end

            if !source_contents.empty?
              error_msg << source_contents
            end

            error_msg << "\nNested exception:" << e.message << "\n"

            Kernel::raise MobyBase::VerificationError.new(error_msg)

          end

        end

        sleep TIMEOUT_CYCLE_SECONDS

        refresh_suts if counter == ref_counter

      end # do

    rescue Exception => e

      execute_on_error_verify_block unless @@on_error_verify_block.nil?

      raise if e.kind_of? MobyBase::ContinuousVerificationError

      $logger.enabled = logging_enabled
      $logger.log "behaviour" , "FAIL;Verification #{message.nil? ? '' : '\"' << message << '\" '}failed: #{e.to_s}#{timeout.nil? ? '' : ' using timeout ' + timeout.to_s}.;#{self.kind_of?(MobyBase::SUT) ? self.id.to_s + ';sut' : ';'};{};verify;"
      Kernel::raise e

    ensure

      MobyBase::TestObjectFactory.instance.timeout = original_sync_timeout unless original_sync_timeout.nil?

    end

    $logger.enabled = logging_enabled
    $logger.log "behaviour" , "PASS;Verification #{message.nil? ? '' : '\"' << message << '\" '}at #{verify_caller} was successful#{timeout.nil? ? '' : ' using timeout ' + timeout.to_s}.;#{self.kind_of?(MobyBase::SUT) ? self.id.to_s + ';sut' : ';'};{};verify;"

    return nil

  end

  # Verifies that the block given to this method throws an exception while being evaluated. Verification is synchronized with all connected suts.
  # If this method is called for a sut, synchronization is only done with that sut.
  #
  # === params
  # timeout:: (optional) Integer defining the amount of seconds during which the verification must pass.
  # message:: (optional) A String that is displayed as additional information if the verification fails.
  # === returns
  # nil
  # === raises
  # ArgumentError:: message was not a String or timeout an integer, or no block was given.
  # VerificationError:: The verification failed.
  def verify_not( timeout = nil, message = nil, &block )

    logging_enabled = $logger.enabled
    verify_caller = caller(1).first.to_s
    begin

      $logger.enabled = false
      Kernel::raise ArgumentError.new("No block was given.") unless block_given?
      Kernel::raise ArgumentError.new("Argument timeout was not an Integer.") unless timeout.nil? or timeout.kind_of?(Integer)
      Kernel::raise ArgumentError.new("Argument message was not a String.") unless message.nil? or message.kind_of?(String)

      #Set the testobject timeout to 0 for the duration of the verify call
      original_sync_timeout = MobyBase::TestObjectFactory.instance.timeout
      MobyBase::TestObjectFactory.instance.timeout = 0

      timeout_time = get_end_time(timeout)
      #TIMEOUT_CYCLE_SECONDS

      loop do
        counter = ref_counter
        artificial_exception_raised = false
        begin # catch errors thrown in the provided block

          yield
          artificial_exception_raised = true
          Kernel::raise "test"
        rescue Exception => e
          raise if e.kind_of? MobyBase::ContinuousVerificationError

          source_contents = ""
          error_msg = ""

          if (!artificial_exception_raised)
            # an error was encountered => verification ok
            break
          end

          if Time.new > timeout_time

            error_msg = "Verification #{message.nil? ? '' : '"' << message.to_s << '" '}at #{verify_caller} failed\n"

            source_contents = MobyUtil::KernelHelper.find_source(verify_caller)

            if !source_contents.empty?
              error_msg << source_contents
            end

            Kernel::raise MobyBase::VerificationError.new(error_msg)

          end

          sleep TIMEOUT_CYCLE_SECONDS

          refresh_suts if counter == ref_counter

        end

      end # do


    rescue Exception => e

      execute_on_error_verify_block unless @@on_error_verify_block.nil?

      raise if e.kind_of? MobyBase::ContinuousVerificationError

      $logger.enabled = logging_enabled
      $logger.log "behaviour" , "FAIL;Verification #{message.nil? ? '' : '\"' << message << '\" '}failed: #{e.to_s}#{timeout.nil? ? '' : ' using timeout ' + timeout.to_s}.;#{self.kind_of?(MobyBase::SUT) ? self.id.to_s + ';sut' : ';'};{};verify_not;"
      Kernel::raise e

    ensure

      MobyBase::TestObjectFactory.instance.timeout = original_sync_timeout unless original_sync_timeout.nil?

    end

    $logger.enabled = logging_enabled
    $logger.log "behaviour" , "PASS;Verification #{message.nil? ? '' : '\"' << message << '\" '}at #{verify_caller} was successful#{timeout.nil? ? '' : ' using timeout ' + timeout.to_s}.;#{self.kind_of?(MobyBase::SUT) ? self.id.to_s + ';sut' : ';'};{};verify_not;"
    return nil

  end

  # Verifies that the block given to this method evaluates to the expected value. Verification is synchronized with all connected suts.
  # If this method is called for a sut, synchronization is only done with that sut.
  #
  # === params
  # expected:: Expected result value of the block
  # timeout:: (optional) Integer defining the amount of seconds during which the verification must pass.
  # message:: (optional) A String that is displayed as additional information if the verification fails.
  # === returns
  # nil
  # === raises
  # ArgumentError:: message was not a String or timeout an integer, or no block was given.
  # VerificationError:: The verification failed.
  # RuntimeError:: An unexpected error was encountered during verification.
  def verify_equal( expected, timeout = nil, message = nil, &block )
    logging_enabled = $logger.enabled
    verify_caller = caller(1).first.to_s
    begin
      $logger.enabled = false
      Kernel::raise ArgumentError.new("No block was given.") unless block_given?
      Kernel::raise ArgumentError.new("Argument timeout was not an Integer.") unless timeout.nil? or timeout.kind_of?(Integer)
      Kernel::raise ArgumentError.new("Argument message was not a String.") unless message.nil? or message.kind_of?(String)

      #Set the testobject timeout to 0 for the duration of the verify call
      original_sync_timeout = MobyBase::TestObjectFactory.instance.timeout
      MobyBase::TestObjectFactory.instance.timeout = 0

      timeout_time = get_end_time(timeout)

      #TIMEOUT_CYCLE_SECONDS

      loop do
        counter = ref_counter
        begin # catch errors thrown due to verification results

          begin # catch errors thrown in the provided block
            result = yield

          rescue Exception => e
            raise if e.kind_of? MobyBase::ContinuousVerificationError
            error_msg = "Verification #{message.nil? ? '' : '"' << message.to_s << '" '}at #{verify_caller} failed as an exception was thrown when the verification block was executed."
            error_msg << MobyUtil::KernelHelper.find_source(verify_caller)
            error_msg << "\nDetails: "
            error_msg << "\n" << e.inspect
            raise MobyBase::VerificationError.new(error_msg)
          end
          if result != expected
            error_msg = "Verification #{message.nil? ? '' : '"' << message.to_s << '" '}at #{verify_caller} failed:"
            error_msg << MobyUtil::KernelHelper.find_source(verify_caller)
            error_msg << "\nThe block did not return #{expected.inspect}. It returned: " << result.inspect
            raise MobyBase::VerificationError.new(error_msg)
          end
          # break loop if no exceptions thrown
          break

        rescue MobyBase::VerificationError => ve

          # refresh and retry unless timeout reached

          if Time.new > timeout_time
            Kernel::raise ve
          end

          sleep TIMEOUT_CYCLE_SECONDS

          refresh_suts if counter == ref_counter
        rescue MobyBase::ContinuousVerificationError
          raise
        rescue Exception => e
          raise if e.kind_of? MobyBase::ContinuousVerificationError
          # an unexpected error has occurred
          Kernel::raise RuntimeError.new("An unexpected error was encountered during verification:\n" << e.inspect )

        end # begin, catch any VerificationErrors

      end # do

    rescue Exception => e

      execute_on_error_verify_block unless @@on_error_verify_block.nil?

      raise if e.kind_of? MobyBase::ContinuousVerificationError

      $logger.enabled = logging_enabled
      $logger.log "behaviour" , "FAIL;Verification #{message.nil? ? '' : '\"' << message << '\" '}failed:#{e.to_s}.\n#{timeout.nil? ? '' : ' using timeout ' + timeout.to_s}.;#{self.kind_of?(MobyBase::SUT) ? self.id.to_s + ';sut' : ';'};{};verify_equal;" << expected.to_s
      Kernel::raise e
    ensure
      MobyBase::TestObjectFactory.instance.timeout = original_sync_timeout unless original_sync_timeout.nil?
    end

    $logger.enabled = logging_enabled
    $logger.log "behaviour" , "PASS;Verification #{message.nil? ? '' : '\"' << message << '\" '}at #{verify_caller} was successful#{timeout.nil? ? '' : ' using timeout ' + timeout.to_s}.;#{self.kind_of?(MobyBase::SUT) ? self.id.to_s + ';sut' : ';'};{};verify_equal;" << expected.to_s
    return nil

  end

  # Verifies that the block given to this method evaluates to true. Verification is synchronized with all connected suts.
  # If this method is called for a sut, synchronization is only done with that sut.
  #
  # === params
  # timeout:: (optional) Integer defining the amount of seconds during which the verification must pass.
  # message:: (optional) A String that is displayed as additional information if the verification fails.
  # === returns
  # nil
  # === raises
  # ArgumentError:: message was not a String or timeout an integer, or no block was given.
  # VerificationError:: The verification failed.
  # RuntimeError:: An unexpected error was encountered during verification.
  def verify_true( timeout = nil, message = nil, &block )

    logging_enabled = $logger.enabled
    verify_caller = caller(1).first.to_s

    begin
      $logger.enabled = false
      Kernel::raise ArgumentError.new("No block was given.") unless block_given?
      Kernel::raise ArgumentError.new("Argument timeout was not an Integer.") unless timeout.nil? or timeout.kind_of?(Integer)
      Kernel::raise ArgumentError.new("Argument message was not a String.") unless message.nil? or message.kind_of?(String)

      #Set the testobject timeout to 0 for the duration of the verify call
      original_sync_timeout = MobyBase::TestObjectFactory.instance.timeout
      MobyBase::TestObjectFactory.instance.timeout = 0

      timeout_time = get_end_time(timeout)
      #TIMEOUT_CYCLE_SECONDS

      loop do

        counter = ref_counter

        begin # catch errors thrown due to verification results


          begin # catch errors thrown in the provided block

            result = yield

          rescue Exception => e

            #@@on_error_verify_block.call unless @@on_error_verify_block.nil?

            raise if e.kind_of? MobyBase::ContinuousVerificationError

            error_msg = "Verification #{message.nil? ? '' : '"' << message.to_s << '" '}at #{verify_caller} failed as an exception was thrown when the verification block was executed."
            error_msg << MobyUtil::KernelHelper.find_source(verify_caller)
            error_msg << "\nDetails: "
            error_msg << "\n" << e.inspect

            raise MobyBase::VerificationError.new( error_msg )

          end

          unless result == true

            error_msg = "Verification #{message.nil? ? '' : '"' << message.to_s << '" '}at #{verify_caller} failed."
            error_msg << MobyUtil::KernelHelper.find_source(verify_caller)

            error_msg << "\nThe block did not return true. It returned: " << result.inspect

            raise MobyBase::VerificationError.new( error_msg )

          end

          # break loop if no exceptions thrown
          break

        rescue MobyBase::VerificationError => ve

          # refresh and retry unless timeout reached

          if ( Time.new > timeout_time )

            execute_on_error_verify_block unless @@on_error_verify_block.nil?

            Kernel::raise ve

          end

          sleep TIMEOUT_CYCLE_SECONDS

          refresh_suts if counter == ref_counter

        rescue Exception => e

          raise if e.kind_of? MobyBase::ContinuousVerificationError

          $logger.enabled = logging_enabled

          # an unexpected error has occurred
          Kernel::raise RuntimeError.new("An unexpected error was encountered during verification:\n" << e.inspect )

        end # begin, catch any VerificationErrors

      end # do

    rescue Exception => e
      raise if e.kind_of? MobyBase::ContinuousVerificationError
      $logger.enabled = logging_enabled
      $logger.log "behaviour" , "FAIL;Verification #{message.nil? ? '' : '\"' << message << '\" '}failed:#{e.to_s}.\n#{timeout.nil? ? '' : ' using timeout ' + timeout.to_s}.;#{self.kind_of?(MobyBase::SUT) ? self.id.to_s + ';sut' : ';'};{};verify_true;"
      Kernel::raise e
    ensure
      MobyBase::TestObjectFactory.instance.timeout = original_sync_timeout unless original_sync_timeout.nil?
    end

    $logger.enabled = logging_enabled
    $logger.log "behaviour" , "PASS;Verification #{message.nil? ? '' : '\"' << message << '\" '}at #{verify_caller} was successful#{timeout.nil? ? '' : ' using timeout ' + timeout.to_s}.;#{self.kind_of?(MobyBase::SUT) ? self.id.to_s + ';sut' : ';'};{};verify_true;"
    return nil

  end

  # Verifies that the block given to this method evaluates to false. Verification is synchronized with all connected suts.
  # If this method is called for a sut, synchronization is only done with that sut.
  #
  # === params
  # timeout:: (optional) Integer defining the amount of seconds during which the verification must pass.
  # message:: (optional) A String that is displayed as additional information if the verification fails.
  # === returns
  # nil
  # === raises
  # ArgumentError:: message was not a String or timeout an integer, or no block was given.
  # VerificationError:: The verification failed.
  # RuntimeError:: An unexpected error was encountered during verification.
  def verify_false( timeout = nil, message = nil, &block )

    logging_enabled = $logger.enabled

    verify_caller = caller(1).first.to_s

    begin

      $logger.enabled = false

      Kernel::raise ArgumentError.new("No block was given.") unless block_given?

      Kernel::raise ArgumentError.new("Argument timeout was not an Integer.") unless timeout.nil? or timeout.kind_of?(Integer)
      Kernel::raise ArgumentError.new("Argument message was not a String.") unless message.nil? or message.kind_of?(String)

      #Set the testobject timeout to 0 for the duration of the verify call
      original_sync_timeout = MobyBase::TestObjectFactory.instance.timeout
      MobyBase::TestObjectFactory.instance.timeout = 0

      timeout_time = get_end_time(timeout)
      #TIMEOUT_CYCLE_SECONDS

      loop do
        counter = ref_counter
        begin # catch errors thrown due to verification results

          begin # catch errors thrown in the provided block
            result = yield
          rescue Exception => e
            raise if e.kind_of? MobyBase::ContinuousVerificationError
            error_msg = "Verification #{message.nil? ? '' : '"' << message.to_s << '" '}at #{verify_caller} failed as an exception was thrown when the verification block was executed."
            error_msg << MobyUtil::KernelHelper.find_source(verify_caller)
            error_msg << "\nDetails: "
            error_msg << "\n" << e.inspect
            raise MobyBase::VerificationError.new(error_msg)
          end

          error_msg = "Verification #{message.nil? ? '' : '"' << message.to_s << '" '}at #{verify_caller} failed:"
          error_msg << MobyUtil::KernelHelper.find_source(verify_caller)
          error_msg << "The block did not return false. It returned: " << result.inspect
          raise MobyBase::VerificationError.new(error_msg) unless result == false

          # break loop if no exceptions thrown
          break

        rescue MobyBase::VerificationError => ve

          # refresh and retry unless timeout reached

          if Time.new > timeout_time
            Kernel::raise ve
          end

          sleep TIMEOUT_CYCLE_SECONDS

          refresh_suts if counter == ref_counter


        rescue Exception => e
          raise if e.kind_of? MobyBase::ContinuousVerificationError
          # an unexpected error has occurred
          $logger.enabled = logging_enabled
          Kernel::raise RuntimeError.new("An unexpected error was encountered during verification:\n" << e.inspect )

        end # begin, catch any VerificationErrors

      end # do

    rescue Exception => e

      execute_on_error_verify_block unless @@on_error_verify_block.nil?

      raise if e.kind_of? MobyBase::ContinuousVerificationError

      $logger.enabled = logging_enabled
      $logger.log "behaviour" , "FAIL;Verification #{message.nil? ? '' : '\"' << message << '\" '}failed:#{e.to_s}.\n #{timeout.nil? ? '' : ' using timeout ' + timeout.to_s}.;#{self.kind_of?(MobyBase::SUT) ? self.id.to_s + ';sut' : ';'};{};verify_false;"

      Kernel::raise e

    ensure
      MobyBase::TestObjectFactory.instance.timeout = original_sync_timeout unless original_sync_timeout.nil?
    end

    $logger.enabled = logging_enabled
    $logger.log "behaviour" , "PASS;Verification #{message.nil? ? '' : '\"' << message << '\" '}at #{verify_caller} was successful#{timeout.nil? ? '' : ' using timeout ' + timeout.to_s}.;#{self.kind_of?(MobyBase::SUT) ? self.id.to_s + ';sut' : ';'};{};verify_false;"
    return nil

  end
  
=end

  private

  def get_end_time( timeout )

    if self.kind_of?( MobyBase::SUT )

      Time.new + ( timeout.nil? ? MobyUtil::Parameter[ self.sut ][ :synchronization_timeout, '30' ].to_i : timeout.to_i )

    else

      Time.new + ( timeout.nil? ? MobyUtil::Parameter[ :synchronization_timeout, '30' ].to_i : timeout.to_i )

    end

  end

  def get_timeout( timeout )
  
    if self.kind_of?( MobyBase::SUT )

      timeout = MobyUtil::Parameter[ self.sut ][ :synchronization_timeout, '30' ].to_i if timeout.nil?

    else

      timeout = MobyUtil::Parameter[ :synchronization_timeout, '30' ].to_i if timeout.nil?

    end
    
    timeout.to_i
      
  end

  # Current count of combined sut refresh calls to all suts
  def ref_counter
    counter = 0
    if self.kind_of? MobyBase::SUT
      counter = self.dump_count
    else
      MobyBase::SUTFactory.instance.connected_suts.each do |sut_id, sut_attributes|
        counter += sut_attributes[:sut].dump_count
      end
    end
    counter
  end

  def verify_refresh(b_use_id=true)
    if self.kind_of? MobyBase::SUT
        begin
          appid = self.get_application_id
        rescue
          appid='-1'
        end
        if appid != "-1" && b_use_id
          self.refresh({:id => appid})
        else
          self.refresh
        end
      else
        #refresh all connected suts
        MobyBase::SUTFactory.instance.connected_suts.each do |sut_id, sut_attributes|
          begin
            appid = sut_attributes[:sut].get_application_id
          rescue
            appid='-1'
          end
          if appid != "-1" && b_use_id
            sut_attributes[:sut].refresh({:id => appid}) if sut_attributes[:is_connected]
          else
            sut_attributes[:sut].refresh if sut_attributes[:is_connected]
          end
        end
      end
  end

  # Refresh ui state inside verify
  def refresh_suts
    begin
      verify_refresh
      # Ignore all availability errors
    rescue RuntimeError, MobyBase::ApplicationNotAvailableError => e
      begin
        verify_refresh(false)
      rescue RuntimeError, MobyBase::ApplicationNotAvailableError => e
        # This occurs when no applications are registered to sut
        if !(e.message =~ /no longer available/)
          puts 'Raising exception'
          # all other errors are passed up
          raise e
        end
      end
    end
  end

end

module MattiVerify
  include TDriverVerify

end
