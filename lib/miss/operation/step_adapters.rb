require "dry-container"
require "dry-transaction"
require "dry-monads"

module Miss
  module Operation
    class StepAdapters
      extend Dry::Container::Mixin

      class Base
        include Dry::Monads::Either::Mixin
      end

      register :step, Dry::Transaction::StepAdapters::Raw.new
      register :map, Dry::Transaction::StepAdapters::Map.new
      register :tee, Dry::Transaction::StepAdapters::Tee.new


      class Try < Base

        def call(step, *args, input)
          unless step.options[:catch]
            raise ArgumentError, "+try+ steps require one or more exception classes provided via +catch:+"
          end

          Right(step.operation.call(*args, input))
        rescue *Array(step.options[:catch]) => e
          e = step.options[:raise].new(e.message) if step.options[:raise]
          Left([step.options[:failure], e])
        end
      end
      register :try, Try.new


      class TeeTry < Base

        def call(step, *args, input)
          result = Try.new.call(step, *args, input)
          result.right? ? Right(input) : result
        end
      end
      register :tee_try, TeeTry.new


      class Validate < Base

        def call(step, *args, input)

          if step.options[:call_with_args]
            result = step.operation.call(*args, input)
          else
            result = step.operation.call(input)
          end

          if result.success?
            Right(result.output)
          else
            Left([step.options[:failure], result.messages(locale: 'pt-BR')])
          end
        end
      end
      register :validate, Validate.new


      class TeeValidate < Base

        def call(step, *args, input)
          result = Validate.new.call(step, *args, input)
          result.right? ? Right(input) : result
        end
      end
      register :tee_validate, TeeValidate.new


      class Load < Base

        def call(step, *args, input)
          result = step.operation.call(*args, input)
          result.is_a?(Dry::Monads::Either) ? result : Right(input)
        end
      end
      register :load, Load.new
    end
  end
end
