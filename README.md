# dbrunner

`rails dbrunner` — run SQL like `rails runner` runs Ruby.

Rails has `runner`, `console`, and `dbconsole`. Now it has `dbrunner`.

## But wait, there's `db:console`

Yeah, and you can STDIN to it if you have your database client installed on the machine you want to run things on. You also don't get output formatting.

## Install

```ruby
gem "dbrunner"
```

## Usage

```bash
# inline SQL
bin/rails dbrunner "SELECT * FROM users LIMIT 5"

# from a file
bin/rails dbrunner query.sql

# from stdin
echo "SELECT 1" | bin/rails dbrunner -

# JSON output
bin/rails dbrunner -f json "SELECT * FROM users LIMIT 5"

# CSV output
bin/rails dbrunner -f csv "SELECT * FROM users"

# specific database (multi-db)
bin/rails dbrunner --db secondary "SELECT 1"

# specific environment
bin/rails dbrunner -e production "SELECT count(*) FROM users"
```

## Output formats

**Table** (default):

```
id | email              | created_at
---+--------------------+--------------------------
1  | alice@example.com  | 2026-01-15 08:30:00 UTC
2  | bob@example.com    | 2026-02-20 14:15:00 UTC

2 row(s)
```

**JSON** (`-f json`):

```json
[
  { "id": 1, "email": "alice@example.com" },
  { "id": 2, "email": "bob@example.com" }
]
```

**CSV** (`-f csv`):

```
id,email
1,alice@example.com
2,bob@example.com
```

## How it works

The gem registers a Rails command at `rails/commands/dbrunner/dbrunner_command.rb`. Rails discovers it automatically through its command lookup paths — no railtie or initializer needed. It uses `ActiveRecord::Base.lease_connection` to execute queries through your existing database configuration.

## License

MIT
