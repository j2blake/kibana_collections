#
# This monkey patch adds a method to Hash that creates a HashPath
#
class Hash
  def at(*path_and_selector)
    return Populate::HashPath::HashBase.new(self).at(*path_and_selector)
  end
  def pick(*path_and_selector_and_value)
    return Populate::HashPath::HashBase.new(self).pick(*path_and_selector_and_value)
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
        branch = locate_if_present
        return branch ? branch[@selector] : nil
      end

      #
      # If the value at this path is an array of hashes, get an array of values at this path
      # in each hash.
      #
      # If not an array of hashes, return nil.
      #
      def values(path)
        array_of_hashes = self.get
        return nil unless array_of_hashes.is_a?(Array)
        return array_of_hashes.select {|h| h.is_a?(Hash)}.map {|h| h.at(path).get}.reject {|v| v == nil}
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
#        puts "----------<<: value=#{value}, true_value=#{true_value}, self=#{self}"
        append_value(locate_or_create, true_value) if true_value
        return root
      end

      def resolve_value(value)
        value = value.get if value.is_a?(Populate::HashPath::HashPath)
        value = value[0] if value.is_a?(Array) && value.size == 1
        return nil if value == nil || value == "" || value == []
        return value
      end

      def append_value(here, value)
        existing = here[@selector]
        if existing
          here[@selector] = [*existing] + [*value]
        else
          here[@selector] = value
        end
      end

      #
      # Create a path on this HashPath parent
      #
      def at(*path_and_selector)
        ps = path_and_selector.slice(0..-2)
        selector = path_and_selector.slice(-1)
        return HashPathAt.new(self, ps, selector)
      end

      #
      # Create a path on this HashPath parent
      #
      def pick(*path_and_selector_and_value)
        psv = path_and_selector_and_value.slice(0..-3)
        selector = path_and_selector_and_value.slice(-2)
        value = path_and_selector_and_value.slice(-1)
        true_value = resolve_value(value)
        return HashPathPick.new(self, psv, selector, true_value)
      end
    end

    class HashPathAt < HashPath
      def initialize(parent, path, selector)
        @parent = parent
        @path = path
        @selector = selector
      end

      def root
        @parent.root
      end

      def locate_if_present
        here = @parent.locate_if_present
#        puts "LIP:Here from parent: #{here}, #{@parent}"
        @path.each do |p|
          return nil unless here.is_a?(Hash)
          here = here[p]
#          puts "LIP:Here from path "#{p}": #{here}, #{self}"
        end
        return here
      end

      def locate_or_create
        here = @parent.locate_or_create
#        puts "LOC:Here from parent: #{here}, #{@parent}"
        @path.each do |p|
          here[p] = {} unless here[p].is_a?(Hash)
          here = here[p]
#          puts "LOC:Here from path: #{here}, #{self}"
        end
        return here
      end

      def to_s
        "HashPathAt[#{(@path + [@selector]).join(' ')}, parent=#{@parent}]"
      end
    end

    class HashPathPick < HashPath
      def initialize(parent, path, selector, value)
        @parent = parent
        @path = path
        @selector = selector
        @value = value
      end

      def root
        @parent.root
      end

      def locate_if_present
        here = @parent.locate_if_present
#        puts "LIP:Here from parent: #{here}, #{@parent}"
        @path.each do |p|
          return nil unless here.is_a?(Hash)
          here = here[p]
#          puts "LIP:Here from path: #{here}, #{self}"
        end
        return nil unless here.is_a?(Array)
        return here.find do |h|
          h.is_a?(Hash) && h[@selector] == @value
        end
      end

      # A little tricky because the last piece of the path must point to an array of Hashes, instead of a single Hash
      def locate_or_create
        branch_path = Array.new(@path)
        leaf_path = branch_path.pop

        here = @parent.locate_or_create
#        puts "LOC:Here from parent: #{here}, #{@parent}"
        branch_path.each do |p|
          here[p] = {} unless here[p].is_a?(Hash)
          here = here[p]
#          puts "LOC:Here from path: #{here}, #{self}"
        end

        here[leaf_path] = [] unless here[leaf_path].is_a?(Array)
        array = here[leaf_path]
#        puts "array: #{array}"

        found = array.find do |h|
          h.is_a?(Hash) && h[@selector] == @value
        end

        if !found
          found = {@selector => @value}
          array << found
        end

#        puts "found: #{found}"
        return found
      end

      def to_s
        "HashPathPick[#{(@path + [@selector]).join(' ')}, value=#{@value}, parent=#{@parent}]"
      end
    end

    class HashBase < HashPath
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

      def to_s
        "Hash[]"
      end
    end
  end
end