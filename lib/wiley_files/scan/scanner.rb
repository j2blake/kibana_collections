require 'csv'

module WileyFiles
  module Scan
    class Scanner
      #
      # Load that file with the options provided. By default, :headers is set to true.
      #
      def load_csv_file(filename, options = {})
        options = {headers: true}.merge(options)
        
        string = File.read(filename, encoding: "UTF-8")

        array = []
        CSV.parse(string, options) do |row|
          row_hash = {}
          row.each do |key, value|
            row_hash[key] = value.is_a?(String) ? value.strip : value
          end
          array << row_hash
        end
        return array
      end
    end
  end
end