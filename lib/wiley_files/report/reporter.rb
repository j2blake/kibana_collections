module WileyFiles
  module Report
    class Reporter
      def initialize
        @template_map = {}
      end

      def set_template(key, template_string)
        @template_map[key] = template_string
      end

      def lookup(template)
        template_string = @template_map[template]
        return template_string || template.to_s
      end

      def report(template, values = {})
        puts lookup(template) % values
      end
    end
  end
end