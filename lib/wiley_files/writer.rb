module WileyFiles
  class Writer
    def initialize(reporter)
      @reporter = reporter
    end
    
    def write(flattened)
      @reporter.report("BOGUS write")
    end
  end
end