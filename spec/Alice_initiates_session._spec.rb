require_relative 'helper'

describe 'Alice initiates session' do
  it 'sends a client token and gets a relay token' do
    client_token = Base64.strict_encode64 RbNaCl::Random.random_bytes 32
    post '/start_session', client_token

    expect(response.status).to eq 200

    lines = response.body.split "\r\n"
    expect(lines.size).to eq 2

    relay_token, _difficulty = lines
    expect(relay_token.size).to eq 44
  end
end
