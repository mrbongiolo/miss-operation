module Miss
  module Operation

    class Error < StandardError
      def self.===(other)
        other.kind_of?(self)
      end

      def ===(other)
        self.kind_of?(other)
      end
    end

    class EntityNotFoundError < Error; end

    class UnprocessableEntityError < Error
      attr_reader :errors

      def initialize(message = 'Unprocessable Entity', errors: {})
        @errors = errors
        super(message)
      end
    end
  end
end
