require "rhubarb/version"
require "rhubarb/array"
require "rhubarb/routing"
require "rhubarb/util"
require "rhubarb/dependencies"
require "rhubarb/file_model"
require "rhubarb/sqlite_model"
require "rhubarb/controller"

module Rhubarb

  class Application

    def call(env)
      case env["PATH_INFO"]
      when "/"
        return [302, { "Content-Type" => "text/html" }, [QuotesController.new(env).a_quote]]
      when "/favicon.ico"
        return [404, { "Content-Type" => "text/html" }, []]
      else
        klass, action = get_controller_and_action(env)
        controller = klass.new(env)

        begin
          text = controller.send(action)
          response = controller.get_response

          if response
            [response.status, response.headers, [response.body].flatten]
          else
            [200, { "Content-Type" => "text/html" }, [text]]
          end
        rescue => e
          [500, { "Content-Type" => "text/html" }, [e.message]]
        end
      end

    end

  end

end
