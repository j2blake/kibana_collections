module WileyFiles
  module Report
    class PrefixedReporter < Reporter
      def initialize(wrapped, prefix)
        @wrapped = wrapped
        @prefix = prefix
        super()
      end
      
      def report(template, values={})
        @wrapped.report(@prefix + lookup(template), values)
      end
      
      def close
        @wrapped.close
      end
    end
  end
end