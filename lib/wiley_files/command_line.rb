module WileyFiles
  class CommandLine
    def parse
      options = {}
      o = OptionParser.new do |opts|
        opts.banner = "Usage: analyzer.rb data_file_directory [options]"

        options[:output_to] = "NONE"
        opts.on("-o", "--output_to DEST", ["NONE", "STDOUT", "ELASTIC"], *[
          "Write search documents to STDOUT,",
          "   to ELASTIC (requires --index),",
          "   or NONE (default)."
        ]) do |dest|
          options[:output_to] = dest
        end

        opts.on("-i", "--index-name NAME", "The name of the Elasticsearch index to write the records into.") do |index|
          options[:index_name] = index
        end

        opts.on_tail("-h", "--help", "Show this message.") do
          puts opts
          exit
        end
      end

      begin
        o.parse!

        if options[:output_to] == "ELASTIC" && !options[:index_name]
          raise OptionParser::InvalidOption, "You must specify an index name when outputting to ELASTIC" 
        end
        
        return options
      rescue => e
        puts e
        puts o
        exit 1
      end
    end
  end
end
