class ChangeEncoding < ActiveRecord::Migration[6.0]

  def change_encoding(encoding,collation)
    connection = ActiveRecord::Base.connection
    tables = connection.tables
    dbname =connection.current_database
    execute <<-SQL
      ALTER DATABASE #{dbname} CHARACTER SET #{encoding} COLLATE #{collation};
    SQL
    tables.each do |tablename|
      execute <<-SQL
        ALTER TABLE #{dbname}.#{tablename} CONVERT TO CHARACTER SET #{encoding} COLLATE #{collation};
      SQL
    end
  end

  def change
    reversible do |dir|
      dir.up do
        change_encoding('utf8mb4','utf8mb4_unicode_ci')
      end
      dir.down do
        change_encoding('utf8','utf8_general_ci')
      end
    end
  end
end

