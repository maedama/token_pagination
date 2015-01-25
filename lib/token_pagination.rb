require "token_pagination/version"
require "token_pagination/page_token"
require "token_pagination/active_record_relation_extention"
require "token_pagination/railtie"
require "token_pagination/collection"

module TokenPagination
  # Your code goes here...
  class JWTDecodeError < StandardError; end
  class UnmatchCollectionError < StandardError; end
end
