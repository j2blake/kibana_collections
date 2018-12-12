module WileyFiles
  module Report
    class PrefixedReporter < Reporter
      def initialize(parent, prefix, options={})
        super()
        @parent = parent
        @prefix = prefix
        @options = resolve_options(@parent.options, options)
        @template_map = Hash.new {|h, k| @parent.resolve_template(k)}
      end

      def get_prefixes
        @parent.get_prefixes + [@prefix]
      end

      def close
        @parent.push_totals(get_prefixes, @counts)
        if @options[:with_details]
          show_limited
          show_blank
        end
      end
    end
  end
end