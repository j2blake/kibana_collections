module WileyFiles
  module Report
    class Reporter
      include BaseReporterMixin
      NO_LIMIT = 10000000
      DEFAULT_OPTIONS = {with_details: true, with_totals: false, limit: NO_LIMIT}
      SILENT_OPTIONS = {with_details: false, with_totals: false}
      attr_reader :options

      def initialize(options = {})
        @template_map = Hash.new {|h, k| k.to_s}
        @counts = Hash.new(0)
        @options = resolve_options(DEFAULT_OPTIONS, options)
      end

      def resolve_options(defaults, options)
        defaults.merge(options).merge(options.delete(:silent) ? SILENT_OPTIONS : {})
      end

      def set_template(key, template_string)
        @template_map[key] = template_string
      end

      def report(template_id, values = {})
        @counts[template_id] += 1
        write(get_prefixes, resolve_template(template_id), values) if @options[:with_details] && @counts[template_id] <= @options[:limit]
      end

      def get_prefixes
        [Time.now.strftime("%I:%M:%S.%L")]
      end

      def resolve_template(id)
        @template_map[id]
      end

      def write(prefixes, template_string, values)
        puts((prefixes + [template_string % values]).join(" "))
      end

      def close
        show_limited if @options[:with_details]
        show_totals if @options[:with_totals]
        show_blank
      end

      def show_limited
        @counts.each do |id, count|
          if count > @options[:limit]
            write(get_prefixes, ' ', {})
            write(get_prefixes, "...and %{remainder} more: %{id}", id: id, remainder: (count - @options[:limit]))
          end
        end
      end

      def show_totals
        @counts.each do |template_id, count|
          write(get_prefixes, "Total %{id}: %{count}", {id: template_id, count: count})
        end
      end

      def show_blank
        write(get_prefixes, "", {}) if @options[:with_details] || @options[:with_totals]
      end
    end
  end
end
