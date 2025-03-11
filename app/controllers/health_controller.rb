class HealthController < ApplicationController
  def check
    Rails.logger.info "Health check initiated"
    Rails.logger.debug "OpenTelemetry SDK version: #{OpenTelemetry::SDK::VERSION}"
    Rails.logger.debug "Registered instrumentations: #{OpenTelemetry::Instrumentation.registry.map(&:name)}"

    # Create a custom span
    tracer = OpenTelemetry.tracer_provider.tracer('health.check')
    result = nil

    tracer.in_span('database.check') do |span|
      span.set_attribute('database.type', 'postgresql')
      span.add_event('database.query.start')

      begin
        result = ActiveRecord::Base.connection.execute('SELECT 1')
        span.set_attribute('database.query.success', true)
        Rails.logger.debug "Database check successful: #{result.inspect}"
      rescue => e
        span.set_attribute('database.query.success', false)
        span.record_exception(e)
        Rails.logger.error "Database check failed: #{e.message}"
        raise
      ensure
        span.add_event('database.query.end')
      end
    end

    Rails.logger.info "Health check completed successfully"
    render json: {
      status: 'ok',
      time: Time.current,
      otel_enabled: OpenTelemetry.tracer_provider.class != OpenTelemetry::Trace::NoopTracerProvider,
      db_result: result.to_a
    }
  end
end
