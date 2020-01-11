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
#!/usr/bin/env ruby
require 'rdoc/rdoc'

$templates = {}

module RDoc

  class RDoc

    # install custom generator to RDoc
    def install_generator( name, filename )

        GENERATORS[ name.to_s.downcase ] = Generator.new( filename, ( "%sFeatureTestGenerator" % [ name ] ).intern , name.to_s.downcase )

    end

  end

end

def load_templates

  Dir.glob( File.join( File.dirname( File.expand_path( __FILE__ ) ), 'templates', '*.template' ) ).each{ | file |

    name = File.basename( file ).gsub( '.template', '' )

    $templates[ name.to_sym ] = open( file, 'r' ).read

  }

end

if ARGV.count == 0
  
  abort "\nUsage: #{ File.basename( $0 ) } filename.rb\n\n"

else

  ARGV.each{ | filename | 

    abort("\nUnable to create feature test due to implementation file %s not found\n\n" % [ filename ] ) unless File.exist?( File.expand_path( filename ) )

  }

  begin

    load_templates

    RDoc::RDoc.new.tap{ | rdoc |

      rdoc.install_generator( 'TDriver', File.expand_path( File.join( File.dirname( __FILE__ ), 'lib/custom_rdoc_generator.rb' ) ) )

      rdoc.document( ['--inline-source', '--op', 'output', '--fmt', 'tdriver'] + ARGV )

    }

  rescue RDoc::RDocError => e

    abort e.message

  end

end

