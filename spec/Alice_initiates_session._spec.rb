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
    it 'responds with 400 to bad requests' do
      post '/verify_session'
      expect(response.status).to eq 400

      client_token = Base64.strict_encode64 rand_bytes 31
      post '/verify_session', client_token
      expect(response.status).to eq 400

      post '/verify_session', 'some string'
      expect(response.status).to eq 400
    end

    before do
      @client_token = rand_bytes 32

      post '/start_session', @client_token.to_b64
      expect(response.status).to eq 200

      lines = response.body.split "\r\n"
      expect(lines.size).to eq 2

      b64_relay_token, difficulty = lines
      expect(b64_relay_token.size).to eq 44
      expect(difficulty).to eq '0'

      @relay_token = b64_relay_token.from_b64
      expect(@relay_token.size).to eq 32
    end

    context 'when the difficulty is 0' do
      context 'when a client sends valid h2(client_token, relay_token)' do
        it 'sends a r_sess_pk key' do
          h2_ct = h2 @client_token
          h2_ct_and_rt = h2(@client_token + @relay_token)

          post '/verify_session', "#{h2_ct.to_b64}\r\n#{h2_ct_and_rt.to_b64}"
          expect(response.status).to eq 200

          r_sess_pk = response.body.from_b64
          expect(r_sess_pk.size).to eq 32
        end
      end

      context 'when a client sends invalid h2(client_token, relay_token)' do
        it 'responds with 401' do
          h2_ct = h2 @client_token
          h2_ct_and_rt = h2(@relay_token + @client_token)

          post '/verify_session', "#{h2_ct.to_b64}\r\n#{h2_ct_and_rt.to_b64}"
          expect(response.status).to eq 401
        end
      end
    end

    context 'when the difficulty is higher than 0' do
      it 'checks that the first difficulty bits of h2(client_token, relay_token, diff_nonce) are 0'
    end
  end
end
