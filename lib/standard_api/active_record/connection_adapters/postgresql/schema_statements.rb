require 'active_record/connection_adapters/postgresql_adapter'

module StandardAPI
  module ActiveRecord
    module ConnectionAdapters
      class PostgreSQL
        module SchemaStatements
          # Returns a comment stored in database for given table
          def database_comment(database_name=nil) # :nodoc:
            database_name ||= current_database
    
            scope = quoted_scope(database_name, type: "BASE TABLE")
            if scope[:name]
              query_value(<<~SQL, "SCHEMA")
                SELECT pg_catalog.shobj_description(d.oid, 'pg_database')
                FROM   pg_catalog.pg_database d
                WHERE  datname = #{scope[:name]};
              SQL
            end
          end
  
        end
      end
    end
  end
end

ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.include(StandardAPI::ActiveRecord::ConnectionAdapters::PostgreSQL::SchemaStatements)