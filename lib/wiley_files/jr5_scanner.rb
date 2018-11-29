module WileyFiles
  class Jr5Scanner < JrScanner
    def initialize(filename, reporter)
      super
    end
    def flatten
      @records = []
      return @records
    end
  end
end
