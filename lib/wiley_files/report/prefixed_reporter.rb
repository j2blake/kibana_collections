module WileyFiles
  module Report
    class PrefixedReporter < Reporter
      def initialize(wrapped, prefix)
        @wrapped = wrapped
        @prefix = prefix
        super()
      end
      
      def report(template, values={})
        super(@prefix + template, values)
      end
    end
  end
end