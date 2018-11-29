module WileyFiles
  module Report
    class LimitingReporter < Reporter
      def initialize(wrapped, limit)
        @wrapped = wrapped
        @limit = limit
        @counts = Hash.new(0)
        super()
      end

      def report(template, values={})
        @counts[template] += 1
        @wrapped.report(template, values) if @counts[template] <= @limit
      end

      def close
        @counts.each do |template, count|
          if count > @limit
            @wrapped.report(' ')
            @wrapped.report "...and %s more: #{template}" % [count - @limit]
          end
        end
        @wrapped.close
      end
    end
  end
end