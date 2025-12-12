def load_sql_dump(file_path = 'db/data/database-dump-for-tests/December12th2025-dump.sql')
  Rails.logger.info "Loading SQL dump"

  db_name = ActiveRecord::Base.connection_db_config.database
  system("psql -d #{db_name} -f #{file_path} -q > /dev/null 2>&1", exception: true)

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
