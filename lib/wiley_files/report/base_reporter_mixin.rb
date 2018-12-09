module WileyFiles
  module Report
    module BaseReporterMixin
      def with_prefix(prefix, options = {})
        prefixed = Report::PrefixedReporter.new(self, prefix, options)
        begin
          if block_given?
            yield prefixed
          end
        ensure
          prefixed.close
        end
      end
    end
  end
end