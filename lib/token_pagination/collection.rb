module TokenPagination
  class Collection < Array
    attr_accessor :next_page_token
  end
end
