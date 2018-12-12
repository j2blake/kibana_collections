=begin

Create a child Reporter with different options from the parent.

=end

module WileyFiles
  module Report
    class ReporterWrapper < Reporter
      def initialize(parent, options={})
        super()
        @parent = parent
        @options = resolve_options(@parent.options, options)
        @template_map = Hash.new {|h, k| @parent.resolve_template(k)}
      end
      
      def get_prefixes
        @parent.get_prefixes
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