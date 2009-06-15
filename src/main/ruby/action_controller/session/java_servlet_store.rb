#--
# Copyright 2007-2009 Sun Microsystems, Inc.
# This source code is available under the MIT license.
# See the file LICENSE.txt for details.
#++

module ActionController
  module Session

    class JavaServletStore
      RAILS_SESSION_KEY = "__current_rails_session"

      class JavaServletSessionHash < AbstractStore::SessionHash
      end

      def initialize(app, *ignored)
        @app = app
      end

      def call(env)
        servlet_request = env['java.servlet_request']
        raise "JavaServletStore should only be used with JRuby-Rack" unless env['java.servlet_request']

        if servlet_session = servlet_request.getSession(false)
          env['java.servlet_session'] = servlet_session
          session = JavaServletSessionHash.new(self, env)
        else
          session = {}
        end

        env[AbstractStore::ENV_SESSION_KEY] = session
        env[AbstractStore::ENV_SESSION_OPTIONS_KEY] = {}

        response = @app.call(env)
      end

      private
      def load_session(env)
        session_id, session = nil, {}
        if servlet_session = env['java.servlet_session']
          session_id = servlet_session.getId
          servlet_session.getAttributeNames.each do |k|
            if k == RAILS_SESSION_KEY
              marshalled_bytes = servlet_session.getAttribute(RAILS_SESSION_KEY)
              if marshalled_bytes
                data = Marshal.load(String.from_java_bytes(marshalled_bytes))
                session.update data if Hash === data
              end
            else
              session[k] = servlet_session.getAttribute(k)
            end
          end
        end
        [session_id, session]
      end
    end
  end
end
