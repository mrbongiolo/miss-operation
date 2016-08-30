require 'spec_helper'

RSpec.describe Miss::Operation do

  class FakeOperation
    include Miss::Operation

    register :schema, -> input {
      unprocessable_entity!({name: 'missing'}) if input[:name].empty?
      {
        name: input[:name].strip
      }
    }

    register :cant_be_arnold, -> input {
      unprocessable_entity!({name: 'can not be Arnold'}) if input[:name] == 'Arnold'
      input
    }

    register :persist, -> input {
      Test::FakeDB << input[:name]
    }

    register :decorate, -> input {
      {
        name: input[:name].upcase
      }
    }

    perform do
      try :schema,
        catch: StandardError
      try :cant_be_arnold,
        catch: StandardError,
        failure: :arnold_not_allowed
      tee :persist
      map :decorate
    end
  end

  class FakeOperationWithArgs
    include Miss::Operation

    register :schema, -> model, input {
      unprocessable_entity!({name: 'missing'}) if input[:name].empty?
      {
        model => {
          name: input[:name].strip
        }
      }
    }

    register :persist, -> model, input {
      Test::FakeDB << "#{model} => #{input[model][:name]}"
    }

    register :decorate, -> model, input {
      {
        model => {
          name: input[model][:name].upcase
        }
      }
    }

    perform do
      try :schema,
        catch: StandardError
      tee :persist
      map :decorate
    end
  end

  before(:each) { Test::FakeDB = [] }

  describe ".call" do

    context "when NOT using .with" do

      context "with a block" do
        let(:result) do
          FakeOperation.call(input) do |m|
            m.success { |output| "Success: #{output}"}
            m.failure(:arnold_not_allowed) { |error| "Sorry! Arnolds are not allowed in here."}
            m.failure { |errors| "Failure: #{errors}"}
          end
        end

        context "with valid input" do
          let(:input) { { name: ' john ' } }

          it "match on success" do
            expect(result).to eql 'Success: {:name=>"JOHN"}'
          end

          it "runs the step operations" do
            result
            expect(Test::FakeDB).to eql ['john']
          end
        end

        context "with invalid input" do

          context "when matching on specified failure" do
            let(:input) { { name: 'Arnold' } }

            it "match on failure" do
              expect(result).to eql 'Sorry! Arnolds are not allowed in here.'
            end

            it "does NOT run the step operations" do
              result
              expect(Test::FakeDB).to eql []
            end
          end

          context "when matching on unspecified failure" do
            let(:input) { { name: '' } }

            it "match on failure" do
              expect(result).to eql 'Failure: {:name=>"missing"}'
            end

            it "does NOT run the step operations" do
              result
              expect(Test::FakeDB).to eql []
            end
          end
        end
      end

      context "without a block" do
        let(:result) { FakeOperation.call(input) }

        context "with valid input" do
          let(:input) { { name: ' john ' } }

          it "the result is a Right Monad" do
            expect(result).to be_a_right_monad
          end

          it "return the result" do
            expect(result.value).to eql({ name: 'JOHN' })
          end

          it "runs the step operations" do
            result
            expect(Test::FakeDB).to eql ['john']
          end
        end

        context "with invalid input" do
          let(:input) { { name: '' } }

          it "the result is a Left Monad" do
            expect(result).to be_a_left_monad
          end

          it "return the result" do
            expect(result).to have_error_on_monad(:name, message: 'missing')
          end

          it "does NOT run the step operations" do
            result
            expect(Test::FakeDB).to eql []
          end
        end
      end
    end

    context "when using .with" do

      context "with a block" do
        let(:result) do
          FakeOperationWithArgs
            .with('customer')
            .call(input) do |m|
              m.success { |output| "Success: #{output}"}
              m.failure { |errors| "Error: #{errors}"}
            end
        end

        context "with valid input" do
          let(:input) { { name: ' john ' } }

          it "match on success" do
            expect(result).to eql 'Success: {"customer"=>{:name=>"JOHN"}}'
          end

          it "runs the step operations" do
            result
            expect(Test::FakeDB).to eql ['customer => john']
          end
        end

        context "with invalid input" do
          let(:input) { { name: '' } }

          it "match on failure" do
            expect(result).to eql 'Error: {:name=>"missing"}'
          end

          it "does NOT run the step operations" do
            result
            expect(Test::FakeDB).to eql []
          end
        end
      end

      context "without a block" do
        let(:result) { FakeOperationWithArgs.with('customer').call(input) }

        context "with valid input" do
          let(:input) { { name: ' john ' } }

          it "the result is a Right Monad" do
            expect(result).to be_a_right_monad
          end

          it "return the result" do
            expect(result.value).to eql({ 'customer' => { name: 'JOHN' } })
          end

          it "runs the step operations" do
            result
            expect(Test::FakeDB).to eql ['customer => john']
          end
        end

        context "with invalid input" do
          let(:input) { { name: '' } }

          it "the result is a Left Monad" do
            expect(result).to be_a_left_monad
          end

          it "return the result" do
            expect(result).to have_error_on_monad(:name, message: 'missing')
          end

          it "does NOT run the step operations" do
            result
            expect(Test::FakeDB).to eql []
          end
        end
      end
    end
  end
end
