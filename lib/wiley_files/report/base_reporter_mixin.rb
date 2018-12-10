module WileyFiles
  module Report
    module BaseReporterMixin
      #
      # Create a child Reporter with different options from the parent.
      #
      def reporter(options = {})
        child = Report::ReporterWrapper.new(self, options)
        if block_given?
          begin
            yield child
          ensure
            child.close
          end
        else
          child
        end
      end

      #
      # Create a child Reporter that adds a prefix to each message, and may have
      # different options from the parent.
      #
      def with_prefix(prefix, options = {})
        child = Report::PrefixedReporter.new(self, prefix, options)
        if block_given?
          begin
            yield child
          ensure
            child.close
          end
        else
          child
        end
      end
    end
  end
end