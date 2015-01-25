require 'jwt'
module TokenPagination
  class PageToken
    attr_reader :c_hash, :pointer_instance
    def initialize(c_hash, pointer_instance)
      @c_hash = c_hash
      @pointer_instance = pointer_instance
    end

    def self.from_string(token_string)
      begin 
        claims, header = JWT.decode(token_string, Rails.application.secrets.secret_key_base)
        return self.new(claims["_ext"]["c_hash"], claims["_ext"]["pointer_instance"])
      rescue JWT::DecodeError => e
        raise TokenPagination::JWTDecodeError.new("token not decoded: #{e.to_s}")
      end
    end

    def to_s	
      JWT.encode({
        _ext: {
          c_hash: @c_hash,
          pointer_instance: @pointer_instance
        }
      }, Rails.application.secrets.secret_key_base)
    end

    def verify_c_hash!(c_hash_string)
      if (c_hash_string != self.c_hash) then
        raise TokenPagination::UnmatchCollectionError.new("c_hash not match")
      end
      self
    end
  end
end
