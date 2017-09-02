require "erubis"
require "rhubarb/file_model"
require "rack/request"

module Rhubarb
  class Controller
    include Rhubarb::Model

    def initialize(env)
      @env = env
    end

    def env
      @env
    end

    def request
      @request ||= Rack::Request.new(@env)
    end

    def params
      request.params
    end

    def render(view_name, locals = {})
      filename = File.join("app", "views", controller_name, "#{view_name}.html.erb")
      template = File.read(filename)
      eruby    = Erubis::Eruby.new(template)
      eruby.result(locals.merge(instance_variables_and_values))
    end

    def controller_name
      klass = self.class.to_s.gsub("Controller", "")
      Rhubarb.to_underscore(klass)
    end

    def instance_variables_and_values
      instance_variables.each_with_object({}) do |var, obj|
        obj[var] = instance_variable_get(var)
      end
    end

  end
end
