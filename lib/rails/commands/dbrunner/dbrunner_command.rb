# frozen_string_literal: true

require "rails/command/environment_argument"

module Rails
  module Command
    class DbrunnerCommand < Base # :nodoc:
      include EnvironmentArgument

      class_option :database, aliases: "--db", type: :string,
        desc: "Specify the database to use."

      class_option :format, aliases: "-f", type: :string, enum: %w[table csv json], default: "table",
        desc: "Output format (table, csv, json)"

      desc "dbrunner [<'SQL'> | <filename.sql> | -]",
        "Run SQL in the context of your database"
      def perform(sql_or_file = nil, *)
        unless sql_or_file
          help
          exit 1
        end

        boot_application!

        sql = resolve_sql(sql_or_file)
        connection = resolve_connection

        result = connection.exec_query(sql)

        if result.columns.any?
          render(result)
        else
          say "#{result.rows.length} row(s) affected"
        end
      rescue ActiveRecord::StatementInvalid => e
        error e.message
        exit 1
      end

      private
        def resolve_sql(sql_or_file)
          if sql_or_file == "-"
            $stdin.read
          elsif File.exist?(sql_or_file)
            File.read(sql_or_file)
          else
            sql_or_file
          end
        end

        def resolve_connection
          require APP_PATH
          ActiveRecord::Base.configurations = Rails.application.config.database_configuration

          env = Rails::Command.environment

          if options[:database]
            configs_for_options = { env_name: env, name: options[:database] }
            configs_for_options[:include_hidden] = true if Gem::Version.new(ActiveRecord::VERSION::STRING) >= Gem::Version.new("7.1")
            db_config = ActiveRecord::Base.configurations.configs_for(**configs_for_options)

            unless db_config
              raise ActiveRecord::AdapterNotSpecified,
                "'#{options[:database]}' database is not configured for '#{env}'."
            end
          else
            db_config = ActiveRecord::Base.configurations.find_db_config(env)

            unless db_config
              raise ActiveRecord::AdapterNotSpecified,
                "No database configured for '#{env}'."
            end
          end

          ActiveRecord::Base.establish_connection(db_config)

          if ActiveRecord::Base.respond_to?(:lease_connection)
            ActiveRecord::Base.lease_connection
          else
            ActiveRecord::Base.connection
          end
        end

        def render(result)
          case options[:format]
          when "json"
            render_json(result)
          when "csv"
            render_csv(result)
          else
            render_table(result)
          end
        end

        def render_json(result)
          require "json"
          rows = result.rows.map { |row| result.columns.zip(row).to_h }
          say JSON.pretty_generate(rows)
        end

        def render_csv(result)
          require "csv"
          say CSV.generate { |csv|
            csv << result.columns
            result.rows.each { |row| csv << row }
          }
        end

        def render_table(result)
          columns = result.columns
          rows = result.rows.map { |row| row.map { |v| v.nil? ? "NULL" : v.to_s } }

          widths = columns.each_with_index.map do |col, i|
            [col.length, *rows.map { |r| r[i].length }].max
          end

          header = columns.each_with_index.map { |col, i| col.ljust(widths[i]) }.join(" | ")
          separator = widths.map { |w| "-" * w }.join("-+-")

          say header
          say separator
          rows.each do |row|
            say row.each_with_index.map { |val, i| val.ljust(widths[i]) }.join(" | ")
          end
          say ""
          say "#{rows.length} row(s)"
        end
    end
  end
end
