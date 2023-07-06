# frozen_string_literal: fpath

require_relative "insta_json_parser/version"
require "json"
require "oj"
require "fileutils"

module InstaJsonParser
  class Error < StandardError; end
  class FileDoesntExistError < StandardError; end
  class SensitiveDataError < StandardError; end
  class EmptyArrayError < StandardError; end

  class Parser
    def initialize(fpath, input_handler: InputHandler.new, batch_size: 100, output_dir: nil)
      @input_handler = input_handler
      input_handler.array_append_callback = lambda do |_array, value|
        return unless value.is_a?(Hash) && value.has_key?("id")

        increment_counter
        to_output(value)
      end

      @file = File.open(fpath, "r")
      @output_dir = output_dir
      @output_handler = new_output_handler(0)

      @batch_size = batch_size
      @counter = 0
    end

    attr_reader :counter

    def perform
      Oj.sc_parse(input_handler, file)
      @output_handler.close
      file.close
    end

    def to_output(value)
      @output_handler.push_object(value)
      return unless batch_limit?

      @output_handler.close
      @output_handler = new_output_handler(current_batch)
    end

    private

    attr_reader :batch_size, :file, :input_handler

    def new_output_handler(batch)
      OutputHandler.new("#{batch}.json", output_dir: @output_dir)
    end

    def increment_counter
      @counter += 1
    end

    def batch_limit?
      @counter % batch_size == 0
    end

    def current_batch
      @counter / batch_size
    end
  end

  # Bad name. not sure about this 'Handler' idea
  class OutputHandler
    def initialize(fname, output_dir: "./output/batches")
      dir = FileUtils.mkdir_p output_dir
      fpath = File.join(output_dir, fname)
      @file   = File.open(fpath, "w")
      @writer = Oj::StreamWriter.new(@file)

      @writer.push_array
    end

    def push_object(obj)
      @writer.push_json(obj.to_json)
    end

    def close
      p "closing file #{@file.path.inspect}"
      @writer.pop_all
      @writer.flush
      @file.close
    end
  end

  # Implelements required interface for Oj.sc_parse to run.
  class InputHandler < Oj::ScHandler
    attr_writer :array_append_callback

    def initialize(sanitizer: DataSanitizer)
      @sanitizer = sanitizer
    end

    def hash_start
      {}
    end

    def hash_set(h, key, value)
      h[key] = sanitizer.perform(key, value)
    rescue SensitiveDataError, EmptyArrayError
      nil
    end

    def array_start
      []
    end

    def array_append(a, v)
      a << v
      @array_append_callback.call(a, v) if @array_append_callback
    end

    def add_value(v)
      v
    end

    def error(message, _line, _column)
      puts __method__.to_s
      p "ERROR: #{message}"
    end

    private

    attr_reader :sanitizer
  end

  class DataSanitizer
    SENSITIVE_KEYS = %w[_id]
    class << self
      # mutate the value as you wish
      def perform(key, value)
        raise SensitiveDataError if SENSITIVE_KEYS.include?(key)

        case value
        when String
          scrub_non_alpha_numeric(value)
        when Array
          value.any? ? value : raise(EmptyArrayError)
        else
          value
        end
      end

      def scrub_non_alpha_numeric(value)
        # TODO: Scrub non alphanumeric
        value
      end
    end
  end
end
