require_relative 'spec_helper'

describe PhpExpectationsHook do
  let(:precompile) { PhpPrecompileHook.new(nil) }

  def req(expectations, content)
    struct expectations: expectations, content: content, test: ''
  end

  def compile_and_run(request)
    request = precompile.compile(request)
    puts request.result[:ast]
    runner.run!(runner.compile(request))
  end

  let(:runner) { PhpExpectationsHook.new }
  let(:result) { compile_and_run(req(expectations, code)) }

  context 'expectations' do
    describe 'DeclaresClass' do
      let(:code) { 'class Pepita {}' }
      let(:declares_foo) { {binding: '*', inspection: 'DeclaresClass:Foo'} }
      let(:declares_pepita) { {binding: '*', inspection: 'DeclaresClass:Pepita'} }
      let(:expectations) { [declares_foo, declares_pepita] }

      it { expect(result).to eq [{expectation: declares_foo, result: false}, {expectation: declares_pepita, result: true}] }
    end

    describe 'UsesMath' do
      let(:uses_math) { {binding: '*', inspection: 'UsesMath'} }
      let(:uses_minus) { {binding: '*', inspection: 'Uses:-'} }
      let(:uses_minus_operator) { {binding: '*', inspection: 'UsesMinus'} }
      let(:returns_with_math) { {binding: '*', inspection: 'Returns:WithMath'} }

      context 'when used in explicit return' do
        let(:code) { 'class Pepita { function energy() { return $this->energy - 50; } }' }
        let(:expectations) { [uses_math, uses_minus, returns_with_math] }

        it do
          expect(result).to eq [
              {expectation: uses_math, result: true},
              {expectation: uses_minus_operator, result: true},
              {expectation: returns_with_math, result: true} ]
        end
      end
    end

    describe 'DeclaresMethod' do
      let(:code) { 'class Pepita { function sing() {} } ' }
      let(:declares_methods) { {binding: '*', inspection: 'DeclaresMethod'} }
      let(:declares_sing) { {binding: '*', inspection: 'DeclaresMethod:sing'} }
      let(:pepita_declares_sing) { {binding: 'Pepita', inspection: 'DeclaresMethod:sing'} }
      let(:pepita_declares_vola) { {binding: 'Pepita', inspection: 'DeclaresMethod:vola'} }
      let(:expectations) { [declares_methods, declares_sing, pepita_declares_sing, pepita_declares_vola] }

      it { expect(result).to eq [
          {expectation: declares_methods, result: true},
          {expectation: declares_sing, result: true},
          {expectation: pepita_declares_sing, result: true},
          {expectation: pepita_declares_vola, result: false}] }
    end
  end

end
