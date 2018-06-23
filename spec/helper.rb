require 'rbnacl'
require 'excon'

HOST = '127.0.0.1'
PORT = 8080

require_relative 'core_ext'

module ExconHelpers
  def excon
    @excon ||= Excon.new "http://#{HOST}:#{PORT}"
  end

  def post path, body = ''
    @response = excon.post path: path, body: body
  end

  attr_reader :response
end

module OtherHelpers
  def rand_bytes count
    RbNaCl::Random.random_bytes count
  end

  def h2 msg
    RbNaCl::Hash.sha256 RbNaCl::Hash.sha256 "\0" * 64 + msg
  end
end

RSpec.configure do |config|
  config.include ExconHelpers
  config.include OtherHelpers
end
