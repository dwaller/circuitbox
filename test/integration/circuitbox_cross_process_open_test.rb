require "integration_helper"
require "typhoeus/adapters/faraday"

class Circuitbox

  class FaradayMiddlewareTest < Minitest::Test
    include IntegrationHelpers

    attr_reader :connection, :failure_url

    @@only_once = false
    def setup
      localmemcache_file = "/tmp/circuitbox.lmc"
      @connection = Faraday.new do |c|
        c.use FaradayMiddleware, circuit_breaker_options: { cache: Moneta.new(:LocalMemCache, file: localmemcache_file) }
        c.adapter :typhoeus # support in_parallel
      end
      @failure_url = "http://localhost:4712"


      if !@@only_once
        FakeServer.create(4712, ['500', {'Content-Type' => 'text/plain'}, ["Failure!"]])
      end

      pid = fork do
        con = Faraday.new do |c|
          c.use FaradayMiddleware, circuit_breaker_options: { cache: Moneta.new(:LocalMemCache, file: kyotocabinet_file) }
        end
        volume_threshold = Circuitbox['test'].option_value(:volume_threshold)
        (volume_threshold + 1).times { connection.get(failure_url) }
      end
      Process.wait pid
    end

    def teardown
      Circuitbox.reset
    end

    def test_circuit_is_open
      # LocalMemCache is missing support for increment so this is not working yet
      skip
      response = connection.get(failure_url)
      p response
      # since the child process already opend the circuit we should not query
      # the server therefore we don't have a original_response
      assert response.original_response.nil?
    end
  end
end
