require "rhubarb/version"
require "rhubarb/array"
require "rhubarb/routing"
require "rhubarb/util"
require "rhubarb/dependencies"
require "rhubarb/controller"

module Rhubarb

  class Application

    def call(env)
      # Ghetto hax
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
          [200, { "Content-Type" => "text/html" }, [text]]
        rescue
          [500, { "Content-Type" => "text/html" }, ["Shit hit the fan yo!"]]
        end
      end

    end

  end

end
