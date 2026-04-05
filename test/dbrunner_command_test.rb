# frozen_string_literal: true

require "test_helper"

class DbrunnerCommandTest < Minitest::Test
  include DbrunnerTestHelper

  def setup
    setup_test_table
  end

  def test_runs_inline_sql
    output = dbrunner("SELECT count(*) as total FROM dbrunner_test")
    assert_match "total", output
    assert_match "3", output
  end

  def test_runs_sql_from_file
    sql_file = File.join(DUMMY_APP_PATH, "tmp", "test_query.sql")
    FileUtils.mkdir_p(File.dirname(sql_file))
    File.write(sql_file, "SELECT name FROM dbrunner_test ORDER BY name")

    output = dbrunner(sql_file)
    assert_match "alice", output
    assert_match "bob", output
    assert_match "carol", output
  ensure
    File.delete(sql_file) if File.exist?(sql_file)
  end

  def test_runs_sql_from_stdin
    rails_bin = File.join(DUMMY_APP_PATH, "bin/rails")
    output = `cd #{GEM_ROOT} && echo "SELECT count(*) as total FROM dbrunner_test" | RAILS_ENV=test bundle exec ruby #{rails_bin} dbrunner - 2>&1`
    assert_match "total", output
    assert_match "3", output
  end

  def test_table_format_default
    output = dbrunner("SELECT name, age FROM dbrunner_test WHERE name = 'alice'")
    assert_match "name", output
    assert_match "age", output
    assert_match "alice", output
    assert_match "30", output
    assert_match "1 row(s)", output
  end

  def test_table_format_shows_null
    output = dbrunner("SELECT name, age FROM dbrunner_test WHERE name = 'carol'")
    assert_match "NULL", output
  end

  def test_table_format_separator
    output = dbrunner("SELECT name, age FROM dbrunner_test LIMIT 1")
    assert_match(/^-+\+-+$/, output)
  end

  def test_json_format
    output = dbrunner("-f", "json", "SELECT name, age FROM dbrunner_test ORDER BY name")
    parsed = JSON.parse(output)

    assert_equal 3, parsed.length
    assert_equal "alice", parsed[0]["name"]
    assert_equal 30, parsed[0]["age"]
    assert_equal "bob", parsed[1]["name"]
    assert_nil parsed[2]["age"]
  end

  def test_csv_format
    output = dbrunner("-f", "csv", "SELECT name, age FROM dbrunner_test ORDER BY name")
    rows = CSV.parse(output)

    assert_equal %w[name age], rows[0]
    assert_equal "alice", rows[1][0]
    assert_equal "30", rows[1][1]
    assert_equal 4, rows.length
  end

  def test_multiple_columns_aligned
    output = dbrunner("SELECT name, age FROM dbrunner_test ORDER BY name")
    lines = output.lines.map(&:rstrip)

    header = lines[0]
    assert_match(/name\s+\|\s+age/, header)
  end

  def test_row_count_display
    output = dbrunner("SELECT * FROM dbrunner_test")
    assert_match "3 row(s)", output
  end

  def test_single_row_count_display
    output = dbrunner("SELECT * FROM dbrunner_test WHERE name = 'alice'")
    assert_match "1 row(s)", output
  end

  def test_no_results
    output = dbrunner("SELECT * FROM dbrunner_test WHERE name = 'nobody'")
    assert_match "0 row(s)", output
  end

  def test_invalid_sql
    output = dbrunner("NOT VALID SQL AT ALL", allow_failure: true)
    refute_predicate $?, :success?
  end

  def test_no_argument_shows_help
    output = dbrunner(allow_failure: true)
    assert_equal 1, $?.exitstatus
  end

  def test_help_flag
    output = dbrunner("--help", allow_failure: true)
    assert_match "dbrunner", output
    assert_match "SQL", output
  end

  def test_non_select_statement
    dbrunner("INSERT INTO dbrunner_test (name, age) VALUES ('dave', 40)")

    output = dbrunner("SELECT count(*) as total FROM dbrunner_test")
    assert_match "4", output

    dbrunner("DELETE FROM dbrunner_test WHERE name = 'dave'")
  end

  def test_environment_option
    output = dbrunner("-e", "test", "SELECT count(*) as total FROM dbrunner_test")
    assert_match "3", output
  end

  def test_missing_database
    output = dbrunner("--db", "nonexistent", "SELECT 1", allow_failure: true)
    refute_predicate $?, :success?
  end
end
