# Ruby on Rails Application with OpenTelemetry and Honeycomb Integration

This Rails application demonstrates the integration of OpenTelemetry for observability, with telemetry data being exported to Honeycomb.

## Prerequisites

- Ruby 3.3.0 or later
- PostgreSQL 14 or later
- Honeycomb.io account and API key

## Setup

1. Clone the repository:

```bash
git clone <repository-url>
cd <repository-name>
```

2. Install dependencies:

```bash
bundle install
```

3. Configure environment variables:
   - Copy the `.env.example` file to `.env`
   - Add your Honeycomb API key to the `.env` file:

```bash
HONEYCOMB_API_KEY=your_api_key_here
```

4. Database setup:
   - Ensure PostgreSQL is running:

```bash
# Initialize PostgreSQL database (if not already done)
initdb /usr/local/var/postgresql@14

# Start PostgreSQL
pg_ctl -D '/usr/local/var/postgresql@14' -l logfile start

# Create and migrate the database
rails db:create db:migrate
```

## OpenTelemetry Configuration

The application is configured to use OpenTelemetry for observability. The configuration can be found in `config/initializers/opentelemetry.rb`. Key features include:

- Automatic instrumentation of Rails components
- Integration with Honeycomb.io for telemetry data export
- Instrumentation of:
  - Active Support
  - Rack
  - Action Pack
  - Active Job
  - Active Record
  - Action View
  - Concurrent Ruby
  - Net::HTTP
  - PostgreSQL
  - Rails
  - Rake

## Running the Application

1. Start the Rails server:

```bash
rails server
```

2. Visit `http://localhost:3000` in your browser

## Monitoring and Observability

- Telemetry data is automatically sent to Honeycomb.io
- View your application's telemetry data in the Honeycomb UI
- Monitor:
  - Database queries
  - HTTP requests
  - Controller actions
  - View rendering
  - Background jobs

## Troubleshooting

### PostgreSQL Issues

If you encounter PostgreSQL connection issues:

```bash
# Stop existing PostgreSQL services
brew services stop postgresql
brew services stop postgresql@14

# Initialize a new database cluster (if needed)
initdb /usr/local/var/postgresql@14

# Start PostgreSQL manually
pg_ctl -D '/usr/local/var/postgresql@14' -l logfile start
```

### OpenTelemetry Issues

If you see errors like `OpenTelemetry error: Unable to export spans`, try the following:

1. Verify Honeycomb Configuration:

   ```bash
   # Check if your API key is loaded
   rails runner "puts ENV['HONEYCOMB_API_KEY']"
   ```

   - Ensure the output matches your Honeycomb API key
   - If empty, check that your `.env` file is being loaded

2. Test Honeycomb Connectivity:

   ```bash
   # Test connection to Honeycomb
   curl -I https://api.honeycomb.io:443
   ```

   - Should return HTTP/2 200
   - If connection fails, check your network/firewall settings

3. Common Solutions:

   - Restart the Rails server after updating `.env`
   - Ensure dotenv-rails is in both development and test groups in Gemfile
   - Verify your Honeycomb API key has write permissions
   - Check that your API key is for the correct Honeycomb environment

4. Debug Mode:
   Add to `config/initializers/opentelemetry.rb`:

   ```ruby
   OpenTelemetry::SDK.logger.level = Logger::DEBUG
   ```

5. Verify OpenTelemetry Setup:
   ```bash
   # List installed instrumentation
   rails runner "puts OpenTelemetry::Instrumentation.registry.map(&:name)"
   ```

## Development

The application includes several development tools:

- Brakeman for security analysis
- RuboCop for code style enforcement
- Web Console for debugging
- Capybara and Selenium for system testing

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
