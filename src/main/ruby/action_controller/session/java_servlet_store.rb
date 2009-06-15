#--
# Copyright 2007-2009 Sun Microsystems, Inc.
# This source code is available under the MIT license.
# See the file LICENSE.txt for details.
#++

module ActionController
  module Session
    class JavaServletSessionHash < SessionHash
    end

    class JavaServletStore
      def initialize(app, *ignored)
        @app = app
      end

      def call(env)
        raise "JavaServletStore should only be used with JRuby-Rack" unless env['java.servlet_request']
      end
    end
  end
end
