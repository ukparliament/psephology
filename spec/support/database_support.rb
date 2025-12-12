def load_sql_dump(file_path = 'db/data/database-dump-for-tests/December12th2025-dump.sql')
  Rails.logger.info "Loading SQL dump"

  db_name = ActiveRecord::Base.connection_db_config.database

  command = "psql -d #{db_name} -f #{file_path} -U postgres -h localhost -p 5432 > /dev/null 2>&1"
  system({ "PGPASSWORD" => "postgres" }, command, exception: true)

  Rails.logger.info "Loaded SQL dump"
end

def truncate_all_data_tables
  # Get all table names except schema migrations
  tables = ActiveRecord::Base.connection.tables - ['schema_migrations', 'ar_internal_metadata']

  # Truncate all tables and reset sequences
  ActiveRecord::Base.connection.execute(<<-SQL)
    TRUNCATE TABLE #{tables.join(', ')} RESTART IDENTITY CASCADE;
  SQL
end
