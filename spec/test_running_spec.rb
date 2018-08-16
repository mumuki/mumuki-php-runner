require_relative './spec_helper'

describe PhpTestHook do
  let(:hook) { PhpTestHook.new }

  describe '#run!' do
    let(:file) { hook.compile(treq(content, test, extra)) }
    let(:raw_results) { hook.run!(file) }
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

        it { expect(results).to eq("PHP Parse error:  syntax error, unexpected '!==' (T_IS_NOT_IDENTICAL) in solution.php on line 5\n") }
      end
    end
  end
end


