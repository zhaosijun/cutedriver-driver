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

	# Helper class to store verifyblock for 
	# constant verifications for sut state
	class VerifyBlock 

		attr_accessor :block,:expected, :message,:source, :timeout

		def initialize(block, expected, message = nil, timeout = nil, source = "")

			@block = block
			@expected = expected
			@message = message
			@timeout = timeout
			@source = source

		end

	end

	class KernelHelper

		# Function to determine if given value is boolean
		# == params
		# value:: String containing boolean
		# == returns
		# TrueClass::
		# FalseClass::
		def self.boolean?( value )

			/^(true|false)$/i.match( value.to_s ).kind_of?( MatchData ) rescue false

		end

		# Function to return boolean of given value
		# == params
		# value:: String containing boolean
		# == returns
		# TrueClass::
		# FalseClass::
		def self.to_boolean( value, default = nil )

			/^(true|false)$/i.match( value.to_s ) ? $1.downcase == 'true' : default

		end

		# Function to return class constant from a string
		# == params
		# constant_name:: String containing path
		# == returns
		# Class
		def self.get_constant( constant_name )

			begin

				constant_name.split("::").inject( Kernel ){ | scope, const_name | scope.const_get( const_name ) }

			rescue 

				Kernel::raise NameError.new( "Invalid constant %s" % constant_name )

			end

		end

		def self.parse_caller( at )

			if /^(.+?):(\d+)(?::in `(.*)')?/ =~ at

				file = Regexp.last_match[ 1 ]
				line = Regexp.last_match[ 2 ].to_i
				method = Regexp.last_match[ 3 ]

				[ file, line, method ]

			end

		end

		def self.deprecated( deprecated_name, new_name = "" )

			output = "warning: #{ deprecated_name } is deprecated"

			output += "; use #{ new_name } instead" unless new_name.empty?

			$stderr.puts output

		end

    # Searches for the given source file for a line
    #
    # === params
    # from_file:: String defining the file to load. If at_line is nil, this argument can also contain a path and line number separated by : (eg. some_dir/some_file.rb:123).
    # at_line:: (optional) Integer, number of the line (first line is 1).
    # === returns
    # String:: Contents of the line
    # === throws
    # RuntimeError:: from_file is not correctly formed, the file cannot be loaded or the line cannot be found.
    def self.find_source(backtrace)

      ret_str = "\n"

      begin

        call_stack = backtrace.to_s.split(':')
        #puts "call_stack:" << backtrace.to_s

        line_number = 0
        if (call_stack.size() == 2)
          line_number = call_stack[1].to_i

        else
          line_number = call_stack[call_stack.size()-2].to_i
        end
        #puts "line number: " << line_number.to_s

        file_path = ""
        if (call_stack.size() == 2)
          file_path = call_stack[0]
        else
          (call_stack.size()-2).times do |index|
            file_path << call_stack[index].to_s << ":"
          end
          file_path.slice!(file_path.size()-1) # remove the trailing colon
        end
        #puts "file path: " << file_path.to_s

        lines_to_read = line_number >= 2 ? 3 : line_number
        #puts "lines to read: " << lines_to_read.to_s

        start_line = line_number #- (lines_to_read <= 1 ? 0 : 1)
        #puts "start line:" << start_line.to_s

        File.open(File.expand_path(file_path.to_s), "r") { |source|

          lines = source.readlines
          #puts "lines.size:" << lines.size
          Kernel::raise RuntimeError.new("Only \"#{lines.size.to_s}\" lines exist in the source file.")if start_line > lines.size

          lines_to_read = (lines.size - start_line + 1) < 3 ? (lines.size - start_line + 1) : lines_to_read

          # the array is zero based, first line is at position 0
          lines_to_read.times do |index|
            if (line_number == (start_line + index))
              ret_str << "=> "
            else
              ret_str << "   "
            end
            ret_str << lines[start_line + index - 1]
          end

        }

      rescue Exception => e

        #puts "exception:" << e.inspect
        ret_str << "Unable to load source lines.\n" << e.inspect

      end

      return ret_str

    end



		# enable hooking for performance measurement & debug logging
		MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )

	end # KernelHelper

end # MobyUtil
