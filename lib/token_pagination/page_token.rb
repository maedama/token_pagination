require 'jwt'
module TokenPagination
  class PageToken
    @@config = { secret: "foo" }
    attr_reader :c_hash, :pointer_instance
    def initialize(c_hash, pointer_instance)
      @c_hash = c_hash
      @pointer_instance = pointer_instance
    end

    def self.from_string(token_string)
      claims, header = JWT.decode(token_string, @@config[:secret])
      self.new(claims["_ext"]["c_hash"], claims["_ext"]["pointer_instance"])
    end

    def to_s	
      JWT.encode({
        _ext: {
          c_hash: @c_hash,
          pointer_instance: @pointer_instance
        }
      }, @@config[:secret])
    end
  end
end
