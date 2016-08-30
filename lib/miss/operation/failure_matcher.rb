require "dry-matcher"
require "miss/operation/errors"

module Miss
  module Operation

    FailureMatcher = Dry::Matcher.new(
      success: Dry::Matcher::Case.new(
        match: -> result { result.right? },
        resolve: -> result { result.value }
      ),
      failure: Dry::Matcher::Case.new(
        match: -> result, failure = nil {
          if failure
            result.left? && result.value.value[0] == failure
          else
            result.left?
          end
        },
        resolve: -> result {
          value = result.value.value[1]
          value.is_a?(Miss::Operation::UnprocessableEntityError) ? value.errors : value
        }
      )
    )
  end
end
