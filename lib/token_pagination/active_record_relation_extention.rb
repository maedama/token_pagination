require 'jwt'
require 'digest'
require 'active_support/concern'
require 'token_pagination/page_token'
module TokenPagination
  module ActiveRecordRelationExtention
    extend ActiveSupport::Concern
    included do
      def page_by_token(count, page_token_string=nil)
        begin
          page_by_token!(count, page_token_string)
        rescue TokenPagination::JWTDecodeError
          return TokenPagination::Collection.new([])
        rescue TokenPagination::UnmatchCollectionError
          return TokenPagination::Collection.new([])
        end 
      end

      def page_by_token!(count, page_token_string=nil)
        result_set = self
        
        if self.order_values.empty? then
          raise "Order caluse must be specified"
        end

        unless page_token_string.nil? then
          token = TokenPagination::PageToken.from_string(page_token_string).verify_c_hash!(self.to_c_hash)
          result_set = result_set.where(pointer_to_where_values(token.pointer_instance))
        end
        
        result = result_set.take(count+1)

        if result.size == count+1 then
          result.pop
          pointer_instance =  result.last
          pointer_instance_values = self.order_values.map{|item| item.value.name }.map{| attribute| pointer_instance.send(attribute) }
          next_page_token = TokenPagination::PageToken.new(to_c_hash, pointer_instance_values).to_s
        end

        result = TokenPagination::Collection.new(result)
        result.next_page_token = next_page_token
        result
      end  

      # attribute1 >= val AND (attribute 1 > val or ( attribute2 > val OR ( attribute2 >= val AND attribute3 > val) OR (attribute 2 >= val AND attribute3 >= val AND attribute 4 > val )
      def pointer_to_where_values(pointer_instance)
        orders = self.order_values.dup  # copy
        primal_order = orders.shift
        primal_attribute = primal_order.value.relation[primal_order.value.name]
        primal_value = pointer_instance.shift

        primal_condition =  _eq_or_next(primal_order, primal_attribute, primal_value)
        on_boader_condition = _next(primal_order, primal_attribute, primal_value)
        
        all_eq_upto = primal_attribute.eq(primal_value)

        orders.each do|o|
          attribute = o.value.relation[o.value.name]
          value = pointer_instance.shift

          on_boader_condition = on_boader_condition.or(
            all_eq_upto.and(
              _next(o, attribute, value)
            )
          )
          all_eq_upto =  all_eq_upto.and(attribute.eq(value))
        end
        result = primal_condition.and(on_boader_condition)
        return result
      end

      def to_c_hash
        Digest::MD5.hexdigest(self.to_sql) #TODO
      end

      private 
        # These methods respec mysql behaviour
        # Mysql treets nil as bottom elements when ordered ascending
        # But when specified with where query, column >= NULL returns empty set.
        # These method allows as to order by null

        def _eq_or_next(order, attr, value) 
          if order.ascending? then
            if value.nil? then
              # everything matches
              return nil
            else
              return attr.gteq(value)
            end
          else 
            if value.nil? then
              return attr.eq(nil)
            else
              return attr.lteq(value)
            end
          end
        end

        def _next(order, attr, value)
          if order.ascending? then
            if value.nil? then
              return attr.not_eq(nil)
            else
              return attr.gt(value)
            end
          else 
            if value.nil? then
              return attr.lt(nil) # Nothing matches
            else
              return attr.lt(value) 
            end
          end
        end
    end
  end
end
