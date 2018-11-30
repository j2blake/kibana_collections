#
# This monkey patch adds methods to Hash that create a HashPath
#
class Hash
  def at(*path)
    return Populate::HashPath::HashBase.new(self).at(*path)
  end

  def pick(selector, picker, pick_value)
    return Populate::HashPath::HashBase.new(self).pick(selector, picker, pick_value)
  end
end

#
# This monkey patch adds a method to Array that creates a HashPath
#
class Array
  def pick(picker, pick_value)
    return Populate::HashPath::ArrayBase.new(self, picker, pick_value)
  end
end

module Populate
  module HashPath
    class HashPath
      #
      # Walk down the path into nested Hashes, eventually returning the value found there.
      # If the path does not lead to nested Hashes, return nil
      #
      def get
        return locate_if_present
      end

      #
      # Walk down the path into nested Hashes, if it exists, and return true.
      # If the path does not lead to nested Hashes, return false.
      #
      def found?
        return locate_if_present != nil
      end

      #
      # If the value at this path is an array of hashes, get an array of values at this
      # selector in each hash.
      #
      # If not an array, return nil.
      #
      # If the array contains values that are not hashes, or that do not contain the
      # selector as a key, do not include them in the result
      #
      def values(selector)
        array = self.get
        return [] unless array.is_a?(Array)
        array_of_hashes = array.select {|h| h.is_a?(Hash)}
        array_of_values = array_of_hashes.map {|h| h.at(selector).get}
        return array_of_values.reject {|v| v == nil}
      end

      #
      # Walk down the path, creating hashes as needed, and eventually add the provided value.
      # If a value or an array already exists at the end of path, add this value to the array.
      # Return the hash that is the root of the path.
      #
      # If the value is nil, an empty string, or an empty Array, take no action.
      #
      # If the value is an array with one element, treat it as a single item.
      #
      # If `value` is a HashPath, call value.get to obtain the actual value.
      # This permits a syntax of target.at("here") << source.at("there")
      #
      def <<(value)
        true_value = resolve_value(value)
        append_value(true_value) if true_value
        return root
      end

      def resolve_value(value)
        value = value.get if value.is_a?(HashPath)
        value = value[0] if value.is_a?(Array) && value.size == 1
        return nil if value == nil || value == "" || value == []
        return value
      end

      def append_value(value)
        here = @parent.locate_or_create
        existing = here[@selector]
        if existing.is_a?(Array)
          here[@selector] = existing << value
        elsif existing
          here[@selector] = [existing, value]
        else
          here[@selector] = value
        end
      end

      #
      # Create a path on this HashPath parent
      #
      def at(*path)
        selector = path[0]
        if path.size == 0
          self
        elsif path.size == 1
          at_one_level(selector)
        else path.size > 1
          at_one_level(selector).at(*path[1..-1])
        end
      end

      def at_one_level(selector)
        if selector.is_a?(Array)
          pick(selector[0], selector[1], selector[2])
        else
          HashPathAt.new(self, selector)
        end
      end

      #
      # Create a path on this HashPath parent
      #
      def pick(selector, picker, pick_value)
        return HashPathPick.new(self, selector, picker, pick_value)
      end
    end

    class HashPathAt < HashPath
      attr_reader :parent
      attr_reader :selector
      def initialize(parent, selector)
        @parent = parent
        @selector = selector
      end

      def root
        @parent.root
      end

      def locate_if_present
        here = @parent.locate_if_present
        return nil unless here.is_a?(Hash)
        return here[@selector]
      end

      def locate_or_create
        here = @parent.locate_or_create
        here[@selector] = {} unless here[@selector].is_a?(Hash)
        return here[@selector]
      end

      def ==(other)
        other.is_a?(HashPathAt) && @parent == other.parent && @selector == other.selector
      end

      def to_s
        "HashPathAt[selector=#{@selector}, parent=#{@parent}]"
      end
    end

    class HashPathPick < HashPath
      attr_reader :parent
      attr_reader :selector
      attr_reader :picker
      attr_reader :pick_value
      def initialize(parent, selector, picker, pick_value)
        @parent = parent
        @selector = selector
        @picker = picker
        @pick_value = pick_value
      end

      def root
        @parent.root
      end

      def locate_if_present
        here = @parent.locate_if_present
        return nil unless here.is_a?(Hash)
        return nil unless here[@selector].is_a?(Array)

        return here[@selector].find do |h|
          h.is_a?(Hash) && h[@picker] == @pick_value
        end
      end

      def locate_or_create
        here = @parent.locate_or_create
        here[@selector] = [] unless here[@selector].is_a?(Array)

        found = here[@selector].find do |h|
          h.is_a?(Hash) && h[@picker] == @pick_value
        end

        if !found
          found = {@picker => @pick_value}
          here[@selector] << found
        end

        return found
      end

      def ==(other)
        other.is_a?(HashPathPick) && @selector == other.selector && @picker == other.picker && @pick_value == other.pick_value && @parent == other.parent
      end

      def to_s
        "HashPathPick[selector=#{@selector}, picker=#{@picker}, pick_value=#{@pick_value}, parent=#{@parent}]"
      end
    end

    class HashBase < HashPath
      attr_reader :hash
      def initialize(hash)
        @hash = hash
      end

      def locate_if_present
        return @hash
      end

      def locate_or_create
        return @hash
      end

      def root
        return @hash
      end

      def ==(other)
        other.is_a?(HashBase) && @hash == other.hash
      end

      def to_s
        "HashBase[]"
      end
    end

    class ArrayBase < HashPath
      attr_reader :array
      attr_reader :picker
      attr_reader :pick_value
      def initialize(array, picker, pick_value)
        @array = array
        @picker = picker
        @pick_value = pick_value
      end

      def locate_if_present
        return @array.find do |h|
          h.is_a?(Hash) && h[@picker] == @pick_value
        end
      end

      def locate_or_create
        found = locate_if_present

        if !found
          found = {@picker => @pick_value}
          @array << found
        end

        return found
      end

      def root
        return @array
      end

      def ==(other)
        other.is_a?(ArrayBase) && @picker == other.picker && @pick_value == other.pick_value && @array == other.array
      end

      def to_s
        "ArrayBase[picker=#{@picker}, pick_value=#{@pick_value}]"
      end
    end
  end
end