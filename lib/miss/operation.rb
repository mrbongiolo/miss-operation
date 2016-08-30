require "dry-container"
require "dry-transaction"
require "miss/operation/version"
require "miss/operation/step_adapters"
require "miss/operation/failure_matcher"
require "miss/operation/errors"

module Miss
  module Operation

    def self.included(other)
      other.extend Dry::Container::Mixin
      other.extend ClassMethods
    end

    module ClassMethods

      def transactions
        @_transactions
      end

      def perform(&block)
        @_transactions = Dry.Transaction(
          container: self,
          step_adapters: Miss::Operation::StepAdapters,
          matcher: Miss::Operation::FailureMatcher,
          &block
        )
      end

      def with(*args)
        new(*args)
      end

      def call(input, &block)
        new.call(input, &block)
      end

      def unprocessable_entity!(errors = {})
        raise Miss::Operation::UnprocessableEntityError.new(errors: errors)
      end
    end

    def initialize(*args)
      @_step_options = {}
      self.class.transactions.steps.each do |step|
        @_step_options[step.step_name] = args
      end if args
      self
    end

    def call(input)
      if block_given?
        self.class.transactions.call(input, @_step_options) { |m| yield(m) }
      else
        self.class.transactions.call(input, @_step_options)
      end
    end
  end
end
