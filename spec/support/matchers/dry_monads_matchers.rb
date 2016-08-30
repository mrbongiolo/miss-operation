RSpec::Matchers.define :be_a_monad do
  match do |actual|
    actual.is_a? Dry::Monads::Either
  end

  failure_message do |actual|
    "expected that #{actual} would be a Dry::Monads::Either"
  end

  failure_message_when_negated do |actual|
    "expected that #{actual} would not be a Dry::Monads::Either"
  end

  description do
    "be a Dry::Monads::Either"
  end
end

RSpec::Matchers.define :be_a_right_monad do
  match do |actual|
    actual.is_a? Dry::Monads::Either::Right
  end

  failure_message do |actual|
    "expected that #{actual} would be a Dry::Monads::Either::Right"
  end

  failure_message_when_negated do |actual|
    "expected that #{actual} would not be a Dry::Monads::Either::Right"
  end

  description do
    "be a Dry::Monads::Either::Right"
  end
end

RSpec::Matchers.define :be_a_left_monad do
  match do |actual|
    actual.is_a? Dry::Monads::Either::Left
  end

  failure_message do |actual|
    "expected that #{actual} would be a Dry::Monads::Either::Left"
  end

  failure_message_when_negated do |actual|
    "expected that #{actual} would not be a Dry::Monads::Either::Left"
  end

  description do
    "be a Dry::Monads::Either::Left"
  end
end
