class RouteObject

  def initialize
    @rules = []
  end

  def match(url, *args)
    options = {}
    options = args.pop if args[-1].is_a?(Hash)
    options[:default] ||= {}

    dest = nil
    dest = args.pop if args.size > 0
    raise "Too many args!" if args.size > 0

    parts = url.split("/")
    parts.select! { |p| !p.empty? }

    vars = []
    regexp_parts =
      parts.map do |part|
        if part[0] == ":"
          vars << part[1..-1]
          "([a-zA-Z0-9]+)"
        elsif part[0] == "*"
          vars << part[1..-1]
          "(.*)"
        else
          part
        end
      end

    regexp = regexp_parts.join("/")
    @rules.push({
      regexp: Regexp.new("^/#{regexp}$"),
      vars: vars,
      dest: dest,
      options: options,
    })
  end

  def check_url(url)
    @rules.each do |rule|
      match = rule[:regexp].match(url)

      if match
        options = rule[:options]
        params = options[:default].dup

        # Add vars (e.g. controller, id) to params
        rule[:vars].each.with_index do |var, index|
          params[var] = match.captures[index]
        end

        if rule[:dest]
          return get_dest(rule[:dest], params)
        else
          controller = params["controller"]
          action = params["action"]
          return get_dest("#{controller}##{action}", params)
        end

      end
    end

    nil
  end

  def get_dest(dest, routing_params = {})
    return dest if dest.respond_to?(:call)

    # Extract controller and action
    if dest =~ /^([^#]+)#([^#]+)$/
      name = $1.capitalize
      const = Object.const_get("#{name}Controller")
      return const.action($2, routing_params)
    end

    raise "No destination: #{dest.inspect}!"
  end

end

module Rhubarb
  class Application

    def get_controller_and_action(env)
      _, controller, action, after = env["PATH_INFO"].split('/', 4)
      controller = "#{controller.capitalize}Controller"
      [Object.const_get(controller), action]
    end

    def route(&block)
      @route_obj ||= RouteObject.new
      @route_obj.instance_eval(&block)
    end

    def get_rack_app(env)
      raise "No route!" unless @route_obj
      @route_obj.check_url(env["PATH_INFO"])
    end

  end
end
