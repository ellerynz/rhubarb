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

    def response(text, status = 200, headers = {})
      raise "Already responded!" if @response
      @response = Rack::Response.new([text].flatten, status, headers)
    end

    def get_response
      @response
    end

    def render(*args)
      response(render_view(*args))
    end

    def controller_name
      klass = self.class.to_s.gsub("Controller", "")
      Rhubarb.to_underscore(klass)
    end

    def render_view(view_name, locals = {})
      filename = File.join("app", "views", controller_name, "#{view_name}.html.erb")
      template = File.read(filename)
      eruby    = Erubis::Eruby.new(template)
      eruby.result(locals.merge(instance_variables_and_values))
    end

    def instance_variables_and_values
      instance_variables.each_with_object({}) do |var, obj|
        obj[var] = instance_variable_get(var)
      end
    end

  end
end
