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
      if env["PATH_INFO"] == "/favicon.ico"
        return [404, { "Content-Type" => "text/html" }, []]
      end

      get_rack_app(env).call(env)
    end

  end
end
