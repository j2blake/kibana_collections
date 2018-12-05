module WileyFiles
  module Report
    class MuteReporter < Reporter
      def set_template(key, template_string)
        # do nothing
      end
      
      def report(template, values = {})
        # do nothing
      end
      
      def close
        # do nothing
      end
    end
  end
end