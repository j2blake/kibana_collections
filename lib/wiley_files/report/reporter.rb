=begin
--------------------------------------------------------------------------------

  Write messages to standard output.

  Templates can be set and invoked.

  Options are used to control formatting, suppression, and totals.

  Child reporters can be created with their own options and perhaps a prefix.

--------------------------------------------------------------------------------
=end

module WileyFiles
  module Report
    class Reporter
      include BaseReporterMixin
      NO_LIMIT = 10000000
      DEFAULT_OPTIONS = {with_details: true, with_totals: false, limit: NO_LIMIT}
      SILENT_OPTIONS = {with_details: false, with_totals: false}
      attr_reader :options

      def initialize(options = {})
        # override this in child classes, so they may use their own templates or their parent's.
        @template_map = Hash.new {|h, k| k.to_s}

        # how many times has a template been used on this reporter? Use this to enforce limits.
        @counts = Hash.new(0)

        # how many times has a template been used on this reporter and its children? Use this to print totals.
        @totals = {}

        # children will resolve against their parent's options, not the defaults.
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

      # children may recursively add to this.
      def get_prefixes
        []
      end

      def resolve_template(id)
        @template_map[id]
      end

      def write(prefixes, template_string, values)
        puts(([stamp] + prefixes + [template_string % values]).join(" "))
      end

      def stamp
        Time.now.strftime("%I:%M:%S.%L")
      end

      def close
        show_limited if @options[:with_details]
        if @options[:with_totals]
          push_totals(get_prefixes, @counts)
          show_totals
        end
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

      # children should report their counts when closing, instead of showing totals themselves
      def push_totals(prefixes, counts)
        if self.instance_variable_defined? :@parent
          @parent.push_totals(prefixes, counts)
        else
          @totals[prefixes] = counts
        end
      end

      def show_totals
        show_blank
        write([], "TOTALS", {})
        show_blank
        @totals.each_key.sort { |a, b| a.inspect <=> b.inspect }.each do |prefix_set|
          prefix_string = prefix_set.inspect
          @totals[prefix_set].each_key.sort { |a, b| a.to_s <=> b.to_s }.each do |template_id|
            write(prefix_set, "%{id}: %{count}", {id: template_id, count: @totals[prefix_set][template_id]})
          end
        end
      end

      def show_blank
        write(get_prefixes, "", {}) if @options[:with_details] || @options[:with_totals]
      end
    end
  end
end
