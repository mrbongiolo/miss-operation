RSpec::Matchers.define :have_error_on_monad do |field, opts={}|

  match do |actual|
    @field = field
    @with_message = opts[:message]
    @failure_type = opts[:failure]

    is_a_left_monad?(actual) &&
    has_valid_failure_type?(actual.value[0]) &&
    (
      valid_errors_hash?(actual.value[1]) ||
      valid_miss_unprocessable_entity?(actual.value[1])
    )
  end

  failure_message do |actual|
    "expected that #{ actual } had an error on :#{ field }"
      .concat(added_message)
      .concat(added_failure_type)
      .concat(". Instead got: #{ actual.value }")
  end

  failure_message_when_negated do |actual|
    "expected that #{ actual } did NOT had an error on :#{ field }"
      .concat(added_message)
      .concat(added_failure_type)
      .concat(". Instead got: #{ actual.value }")
  end

  description do
    "have error on #{field}"
  end

  private

  def added_message
    @with_message ? " with message: '#{ @with_message }'" : ""
  end

  def added_failure_type
    @failure_type ? " with failure type: :#{ @failure_type }" : ""
  end

  def is_a_left_monad?(result)
    result.is_a?(Dry::Monads::Either::Left)
  end

  def has_valid_failure_type?(actual_failure_type)
    return true unless @failure_type
    actual_failure_type == @failure_type
  end

  def valid_miss_unprocessable_entity?(entity)
    entity.is_a?(Miss::Operation::UnprocessableEntityError) &&
    include_error?(entity.errors) &&
    include_message?(entity.errors)
  end

  def valid_errors_hash?(entity)
    entity.is_a?(Hash) &&
    include_error?(entity) &&
    include_message?(entity)
  end

  def include_error?(errors)
    errors.include?(@field)
  end

  def include_message?(errors)
    return true unless @with_message
    errors[@field].include?(@with_message)
  end
end
