module WileyFiles
  class Writer
    DEFAULT_MAPPING = "_doc"
    def initialize(options, reporter)
      @options = options
      @reporter = reporter
    end

    def write(docs)
      @reporter.with_prefix("Writer", limit: 5) do |r|
        @r = r
        case @options[:output_to]
        when "STDOUT"
          show_documents(docs)
        when "ELASTIC"
          send_documents(docs)
        end
      end
    end

    def show_documents(docs)
      @r.set_template(:show_documents, "Documents created: %{docs}")

      docs_by_id = {}
      docs.each { |d| docs_by_id[[make_id(d)]] = d }

      @r.report(:show_documents, docs: docs_by_id.pretty_inspect)
    end

    def send_documents(docs)
      @r.set_template(:sent_document, "Sent document %{id}. return code: %{code}, response: %{response}")
      docs.each do |doc|
        id = make_id(doc)
        response = send_to_elasticsearch(id, doc)
        @r.report(:sent_document, id: id, code: response.code, response: response.body)
      end
    end

    def send_to_elasticsearch(id, doc)
      port = 9200
      host = "127.0.0.1"
      path = "/#{@options[:index_name]}/_doc/#{id}"

      req = Net::HTTP::Put.new(path, initheader = { 'Content-Type' => 'application/json'})
      req.body = doc.to_json

      Net::HTTP.new(host, port).start {|http| http.request(req) }
    end

    def make_id(doc)
      doc.hash.to_s
    end
  end
end

=begin
If STDOUT, report the docs (pretty print?)
IF ELASTIC, ship them to elasticsearch and report the total sent, with return codes
Else, put a message.
=end