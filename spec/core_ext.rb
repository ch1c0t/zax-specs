require 'base64'

class String
  def to_b64
    Base64.strict_encode64 self
  end

  def from_b64
    Base64.strict_decode64 self
  end
end
