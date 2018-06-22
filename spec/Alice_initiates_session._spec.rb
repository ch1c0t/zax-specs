require_relative 'helper'

describe 'Alice initiates session' do
  describe '/start_session' do
    it 'receives a client token and responds with a relay token' do
      client_token = Base64.strict_encode64 rand_bytes 32
      post '/start_session', client_token

      expect(response.status).to eq 200

      lines = response.body.split "\r\n"
      expect(lines.size).to eq 2

      relay_token, _difficulty = lines
      expect(relay_token.size).to eq 44
    end

    it 'responds with 400 if there is no client token' do
      post '/start_session'
      expect(response.status).to eq 400
    end

    it 'responds with 401 if a client token is invalid' do
      client_token = Base64.strict_encode64 rand_bytes 31
      post '/start_session', client_token
      expect(response.status).to eq 401

      post '/start_session', 'some string'
      expect(response.status).to eq 401
    end
  end

  describe '/verify_session' do
    context 'when the difficulty is 0' do
      it 'checks that h2(client_token, relay_token) is valid'
    end

    context 'when the difficulty is higher than 0' do
      it 'checks that the first difficulty bits of h2(client_token, relay_token, diff_nonce) are 0'
    end
  end
end
