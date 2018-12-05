module WileyFiles
  module Report
    class Reporter
      def initialize
        @template_map = {}
      end

      def set_template(key, template_string)
        @template_map[key] = template_string
      end
      
      def limit(limit)
        limited = Report::LimitingReporter.new(self, limit)
        yield limited if block_given?
        limited.close
      end
      
      def mute
        yield Report::MuteReporter.new if block_given?
      end
      
      def noop
        yield self if block_given?
      end

      def lookup(template)
        @template_map[template] || template.to_s
      end

      def stamp
        Time.now.strftime("%I:%M:%S.%L")
      end
      
      def report(template, values = {})
        puts "#{stamp} #{lookup(template) % values}"
      end
      
      def close
        puts
      end
    end
  end
end