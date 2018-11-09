require 'csv'
require 'json'
require 'net/http'
require 'pp' #BOGUS

require 'zlib'
require 'populate/hashPath'

module Populate
  class Populator
    def initialize
      @send = ARGV.delete("SEND")
      
      raise "You must supply a filename." unless ARGV.size() > 0
      @filename = ARGV[0]
      raise "File #{@filename} does not exist." unless File.exist?(@filename)

      raise "You must supply an index name." unless ARGV.size > 1
      @index_name = ARGV[1]
    end

    def load_json_file
      File.open(@filename) do |f|
        @input_hash = JSON.load(f)
      end
    end

    def load_csv_file
      @input_array = []
      CSV.foreach(@filename, :headers => true) do |row|
        row_hash = {}
        row.each do |key, value|
          row_hash[key] = value
        end
        @input_array << row_hash
      end
    end

    def send_document(id, mapping, doc)
      @send ? send_to_elasticsearch(id, mapping, doc) : send_to_stdout(id, mapping, doc)
    end

    def send_to_elasticsearch(id, mapping, doc)
      port = 9200
      host = "127.0.0.1"
      path = "/#{@index_name}/#{mapping}/#{id}"

      req = Net::HTTP::Put.new(path, initheader = { 'Content-Type' => 'application/json'})
      req.body = doc.to_json
      response = Net::HTTP.new(host, port).start {|http| http.request(req) }
      puts "BOGUS response code: #{response.code}"
      puts "BOGUS response body: \n#{response.body}"
    end

    def send_to_stdout(id, mapping, doc)
      puts "BOGUS output_document #{id}"
      pp(doc)
    end

  end
end
