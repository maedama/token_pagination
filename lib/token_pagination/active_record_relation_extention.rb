require 'jwt'
require 'active_support/concern'
module TokenPagination
  module ActiveRecordRelationExtention
    extend ActiveSupport::Concern
    included do

    #TODO: compare where hash, to make sure pagetoken can not be used on different condition
      def page_by_token(count, page_token_string=nil)
        result_set = self
    	order = self.order_values
        if (order.size == 0) then
          raise "Order caluse must be specified"
        end
        
        
        token = nil
        if (page_token_string) then
          token = TokenPagination::PageToken.from_string(page_token_string)

          if (self.to_c_hash != token.c_hash) then
            token = nil 
          end
        end    

        if (token) then
          result_set = result_set.where(pointer_to_where_values(token.pointer_instance))
        end 
        
        result = result_set.take(count+1)
        if (result.size == count+1) then
          next_page_token = TokenPagination::PageToken.new(to_c_hash, result.last).to_s
        end   
      
        return result, next_page_token
      end  
    end

    # field1 >= val AND (field 1 > val or ( field2 > val OR ( field2 >= val AND field3 > val) OR (field 2 >= val AND field3 >= val AND field 4 > val )
    def pointer_to_where_values(pointer_instance)
      puts pointer_instance
      orders = self.order_values
      

      primal_order = orders.shift
      primal_field = primal_order.value.name
      primal_value = pointer_instance[primal_field]
      primal_condition = primal_order.ascending? ? arel_table[primal_field].gteq(primal_value) : arel_table[primal_field].lteq(primal_value) 
     
      on_boader_condition = primal_order.ascending? ? arel_table[primal_field].gt(primal_value) : arel_table[primal_field].lt(primal_value)
      all_eq_upto = on_boader_condition = arel_table[primal_field].gt(primal_value)
      
      orders.each do|o|
        field = o.value.name
        value = pointer_instance[field]
          
        on_boader_condition = on_boader_condition.or(all_eq_upto.and(  order.ascending ?  arel_table[field].gt(primal_value) : arel_table[field].lt(primal_value) ))
        all_eq_upto =  all_eq_upto.and(arel_table(field).eq(value))
      end
      result = primal_condition.and(on_boder_condition)
      raise result
      return result
    end
    def to_c_hash
      "hoge"
      #where = self.where_values_hash
      #order = self.order_values
      #table = self.table.name
      #return "#{table}:#{order.to_json}:#{where.to_json}"
    end
  end
end
