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

  # TDriver plugin abstraction class
  class Plugin

    ## plugin configuration, constructor and deconstructor methods
    def self.plugin_name

      raise PluginError, "Plugin name not defined in implementation (#{ self.name })"

    end

    def self.plugin_type

      raise PluginError, "Plugin type not defined in implementation (#{ self.name })"

    end

    def self.plugin_required_tdriver_version

      raise PluginError, "Required TDriver version not defined in plugin implementation (#{ self.name })" 

    end

    def self.register_plugin

      # this method will be called when plugin is registered

    end

    def self.unregister_plugin

      # this method will be called when plugin is unregistered

    end

    # enable hooking for performance measurement & debug logging
    TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

  end # Plugin

end # MobyUtil
