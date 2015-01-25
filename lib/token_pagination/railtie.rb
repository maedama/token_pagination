module TokenPagination
  class Railtie < ::Rails::Railtie
    initializer 'token_pagination' do |_app|
      ActiveSupport.on_load(:active_record) do
        ::ActiveRecord::Relation.send :include, TokenPagination::ActiveRecordRelationExtention
      end  
    end
  end
end
