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

	class DBConnection
		attr_accessor :db_type, :host, :database_name, :username, :password, :dbh
		
		# == description
		# Initialize connection object
		#
		def initialize( db_type, host, database_name, username, password )
			@db_type = db_type.to_s.downcase
			@host = host.to_s.downcase
			@database_name = database_name
			@username = username
			@password = password
			@dbh = nil		
		end

    # enable hoo./base/test_object/factory.rb:king for performance measurement & debug logging
    TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )
		
	end # class

end # module

