require_relative './spec_helper'

describe PhpTestHook do
  let(:precompile_hook) { PhpPrecompileHook.new }
  let(:hook) { PhpTestHook.new }

  describe '#run!' do
    let(:request) { precompile_hook.compile(treq(content, test, extra)) }
    let(:raw_results) { hook.run!(request) }
    let(:results) { raw_results[0] }

    let(:extra) { '' }
    let(:content) { '' }
    let(:test) { '' }

    context 'on simple tests' do
      let(:test) do
        <<PHP
public function testSomethingShouldBe3(): void {
  global $something;
  $this->assertEquals(3, $something);
}
PHP
      end

      context 'when it passes' do
        let(:content) { '$something = 3;' }

        it { expect(results).to eq([['Something should be 3', 'passed', '']]) }
      end

      context 'when it fails' do
        let(:content) { '$something = 135;' }

        it { expect(results).to eq([['Something should be 3', 'failed', 'Failed asserting that 135 matches expected 3.']]) }
      end

      context 'when it throws parse errors' do
        let(:content) { '$something =!==!")=#(" 123;' }

        it { expect(results).to eq("Parse error: syntax error, unexpected '!==' (T_IS_NOT_IDENTICAL) in solution.php on line 5") }
      end
    end
  end
end
