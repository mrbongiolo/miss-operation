require 'spec_helper'

RSpec.describe Miss::Operation::StepAdapters::Try do

  subject { described_class.new }

  describe "#call" do
    let(:result) { subject.call(step, input) }
    let(:step) {
      double('Step',
        operation: operation,
        options: { catch: StandardError })
    }
    let(:operation) {
      -> (input) {
        raise StandardError if input.empty?
        input.upcase
      }
    }

    context "when the result is a Right Monad" do
      let(:input) { 'input' }

      it "return the output of the operation in a Right Monad" do
        expect(result).to be_a_right_monad
        expect(result.value).to eql 'INPUT'
      end
    end

    context "when the result is a Left Monad" do
      let(:input) { '' }

      it "return it" do
        expect(result).to be_a_left_monad
        expect(result.value[0]).to eql nil
        expect(result.value[1]).to be_a StandardError
      end
    end

    context "without the :catch option" do
      let(:step) {
        double('Step',
          operation: operation,
          options: {})
      }
      let(:input) { 'input' }

      it "raises an error" do
        expect do
          result
        end.to raise_error(ArgumentError)
      end
    end
  end
end


RSpec.describe Miss::Operation::StepAdapters::TeeTry do

  subject { described_class.new }

  describe "#call" do
    let(:result) { subject.call(step, input) }
    let(:step) {
      double('Step',
        operation: operation,
        options: { catch: StandardError })
    }
    let(:operation) {
      -> (input) {
        raise StandardError if input.empty?
        input.upcase
      }
    }

    context "when the result is a Right Monad" do
      let(:input) { 'input' }

      it "return the original input in a Right Monad" do
        expect(result).to be_a_right_monad
        expect(result.value).to eql input
      end
    end

    context "when the result is a Left Monad" do
      let(:input) { '' }

      it "return it" do
        expect(result).to be_a_left_monad
        expect(result.value[0]).to eql nil
        expect(result.value[1]).to be_a StandardError
      end
    end

    context "without the :catch option" do
      let(:step) {
        double('Step',
          operation: operation,
          options: {})
      }
      let(:input) { 'input' }

      it "raises an error" do
        expect do
          result
        end.to raise_error(ArgumentError)
      end
    end
  end
end


RSpec.describe Miss::Operation::StepAdapters::Validate do

  subject { described_class.new }

  describe "#call" do

    context "with option :call_with_args" do
      let(:result) { subject.call(step, *args, input) }
      let(:step) {
        double('Step',
          operation: operation,
          options: { call_with_args: true })
      }
      let(:operation) { -> (one, two, input) { schema } }
      let(:input) { 'input' }
      let(:args) { ['foo', 'bar'] }

      context "when the result is a success" do
        let(:schema) {
          double('Schema', success?: true, output: 'output')
        }

        it "return the result output in a Right Monad" do
          expect(result).to be_a_right_monad
          expect(result.value).to eql 'output'
        end
      end

      context "when the result is NOT a success" do
        let(:schema) {
          double('Schema', success?: false, messages: 'errors')
        }

        it "return the result messages in a Left Monad" do
          expect(result).to be_a_left_monad
          expect(result.value).to eql [nil, 'errors']
        end
      end
    end

    context "without option :call_with_args" do
      let(:result) { subject.call(step, input) }
      let(:step) {
        double('Step',
          operation: operation,
          options: { call_with_args: false })
      }
      let(:operation) { -> (input) { schema } }
      let(:input) { 'input' }

      context "when the result is a success" do
        let(:schema) {
          double('Schema', success?: true, output: 'output')
        }

        it "return the result output in a Right Monad" do
          expect(result).to be_a_right_monad
          expect(result.value).to eql 'output'
        end
      end

      context "when the result is NOT a success" do
        let(:schema) {
          double('Schema', success?: false, messages: 'errors')
        }

        it "return the result messages in a Left Monad" do
          expect(result).to be_a_left_monad
          expect(result.value).to eql [nil, 'errors']
        end
      end
    end
  end
end


RSpec.describe Miss::Operation::StepAdapters::TeeValidate do

  subject { described_class.new }

  describe "#call" do

    context "with option :call_with_args" do
      let(:result) { subject.call(step, *args, input) }
      let(:step) {
        double('Step',
          operation: operation,
          options: { call_with_args: true })
      }
      let(:operation) { -> (one, two, input) { schema } }
      let(:input) { 'input' }
      let(:args) { ['foo', 'bar'] }

      context "when the result is a success" do
        let(:schema) {
          double('Schema', success?: true, output: 'output')
        }

        it "return the original input in a Right Monad" do
          expect(result).to be_a_right_monad
          expect(result.value).to eql input
        end
      end

      context "when the result is NOT a success" do
        let(:schema) {
          double('Schema', success?: false, messages: 'errors')
        }

        it "return the result messages in a Left Monad" do
          expect(result).to be_a_left_monad
          expect(result.value).to eql [nil, 'errors']
        end
      end
    end

    context "without option :call_with_args" do
      let(:result) { subject.call(step, input) }
      let(:step) {
        double('Step',
          operation: operation,
          options: { call_with_args: false })
      }
      let(:operation) { -> (input) { schema } }
      let(:input) { 'input' }

      context "when the result is a success" do
        let(:schema) {
          double('Schema', success?: true, output: 'output')
        }

        it "return the original input in a Right Monad" do
          expect(result).to be_a_right_monad
          expect(result.value).to eql input
        end
      end

      context "when the result is NOT a success" do
        let(:schema) {
          double('Schema', success?: false, messages: 'errors')
        }

        it "return the result messages in a Left Monad" do
          expect(result).to be_a_left_monad
          expect(result.value).to eql [nil, 'errors']
        end
      end
    end
  end
end


RSpec.describe Miss::Operation::StepAdapters::Load do
  include Dry::Monads::Either::Mixin

  subject { described_class.new }

  describe "#call" do
    let(:result) { subject.call(step, input) }
    let(:step) { double('Step', operation: operation) }
    let(:operation) {
      -> (input) {
        return Right('output') if input == 'right'
        return Left('output') if input == 'left'
      }
    }

    context "when the result is a Right Monad" do
      let(:input) { 'right' }

      it "return it" do
        expect(result).to be_a_right_monad
        expect(result.value).to eql 'output'
      end
    end

    context "when the result is a Left Monad" do
      let(:input) { 'left' }

      it "return it" do
        expect(result).to be_a_left_monad
        expect(result.value).to eql 'output'
      end
    end

    context "when the result is NOT a Monad" do
      let(:input) { 'blah' }

      it "return the original input in a Right Monad" do
        expect(result).to be_a_right_monad
        expect(result.value).to eql input
      end
    end
  end
end
