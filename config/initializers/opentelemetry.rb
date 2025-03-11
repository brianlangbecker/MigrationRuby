require 'opentelemetry/sdk'
require 'opentelemetry/instrumentation/all'
require 'opentelemetry/exporter/otlp'

# Configure logging for OpenTelemetry
logger = Logger.new(STDOUT)
logger.level = Logger::DEBUG

OpenTelemetry::SDK.configure do |c|
  c.service_name = 'MyRubyApp'
  c.use_all
  c.logger = logger

  # The OTLP exporter will automatically use:
  # OTEL_EXPORTER_OTLP_ENDPOINT
  # OTEL_EXPORTER_OTLP_HEADERS
  c.add_span_processor(
    OpenTelemetry::SDK::Trace::Export::BatchSpanProcessor.new(
      OpenTelemetry::Exporter::OTLP::Exporter.new
    )
  )
end
