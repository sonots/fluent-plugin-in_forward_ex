require 'fluent/plugin/in_forward'

module Fluent
  class ForwardExInput < ForwardInput
    Plugin.register_input('forward_ex', self)

    config_param :stop_file, :string, :default => nil
    config_param :stop_file_interval, :time, :default => 5

    def configure(conf)
      super
    end

    alias_method :original_start, :start
    alias_method :original_shutdown, :shutdown
    
    def start
      if @stop_file
        if File.exist?(@stop_file)
          log.info { "in_forawrd_ex: stop_file \"#{stop_file}\" found. won't activate" }
        else
          original_start
          @active = true
        end
        @stop_file_loop  = Coolio::Loop.new
        @stop_file_timer = TimerWatcher.new(@stop_file_interval, true, log, &method(:on_stop_file_timer))
        @stop_file_loop.attach(@stop_file_timer)
        @stop_file_thread = Thread.new(&method(:stop_file_run))
      end
    end

    def shutdown
      if @stop_file_loop
        @stop_file_loop.watchers.each {|w| w.detach if w.attached? }
        @stop_file_loop.stop if @stop_file_loop.instance_variable_get(:@running)
      end
      deactivate
    end

    def active?
      @active
    end

    def activate
      return if active?
      log.info { "in_forward_ex: stop_file \"#{stop_file}\" disappeared. activate" }
      original_start
      @active = true
    end

    def deactivate
      return unless active?
      log.info { "in_forward_ex: stop_file \"#{stop_file}\" appeared. deactivate" }
      original_shutdown
      @active = false
    end

    class TimerWatcher < Coolio::TimerWatcher
      def initialize(interval, repeat, log, &callback)
        @callback = callback
        @log = log
        super(interval, repeat)
      end

      def on_timer
        @callback.call
      rescue
        @log.error $!.to_s
        @log.error_backtrace
      end
    end

    def stop_file_run
      @stop_file_loop.run(@blocking_timeout)
    rescue => e
      log.error "unexpected error", :error => e, :error_class => e.class
      log.error_backtrace
    end

    def on_stop_file_timer
      if File.exist?(stop_file)
        deactivate
      else
        activate
      end
    end
  end
end
