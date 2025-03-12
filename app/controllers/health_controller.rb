class HealthController < ApplicationController
  def check
    Rails.logger.info "Health check initiated with message: #{params[:message]}"
    Rails.logger.debug "OpenTelemetry SDK version: #{OpenTelemetry::SDK::VERSION}"
    Rails.logger.debug "Registered instrumentations: #{OpenTelemetry::Instrumentation.registry.map(&:name)}"

    # Create a custom span
    tracer = OpenTelemetry.tracer_provider.tracer('health.check')
    result = nil

    tracer.in_span('health.process') do |span|
      # Add the message parameter as a span attribute
      span.set_attribute('health.message', params[:message])
      span.set_attribute('health.timestamp', Time.current.to_i)

      # Simulate some processing based on the message
      if params[:message].present?
        span.add_event('message.processing.start')
        sleep(0.1) # Simulate some work
        span.set_attribute('message.length', params[:message].length)
        span.add_event('message.processing.end')
      end

      # Database check in a nested span
      tracer.in_span('database.check') do |db_span|
        db_span.set_attribute('database.type', 'postgresql')
        db_span.add_event('database.query.start')

        begin
          result = ActiveRecord::Base.connection.execute('SELECT 1')
          db_span.set_attribute('database.query.success', true)
          Rails.logger.debug "Database check successful: #{result.inspect}"
        rescue => e
          db_span.set_attribute('database.query.success', false)
          db_span.record_exception(e)
          Rails.logger.error "Database check failed: #{e.message}"
          raise
        ensure
          db_span.add_event('database.query.end')
        end
      end
    end

    Rails.logger.info "Health check completed successfully"
    render json: {
      status: 'ok',
      time: Time.current,
      message_received: params[:message],
      message_length: params[:message]&.length,
      otel_enabled: OpenTelemetry.tracer_provider.class != OpenTelemetry::Trace::NoopTracerProvider,
      db_result: result.to_a
    }
  end
end
