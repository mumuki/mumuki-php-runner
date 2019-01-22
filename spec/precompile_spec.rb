require_relative './spec_helper'

describe PhpPrecompileHook do
  let(:hook) { PhpPrecompileHook.new(nil) }
  let(:compilation) { hook.compile_test_content(treq(sample_content, sample_test, sample_extra)) }

  let(:sample_extra) { '$extra = 2;' }
  let(:sample_content) { 'class Foo { function bar() { return "baz"; } }' }
  let(:sample_test) {
    <<PHP
public function testFooBarBaz(): void {
  $this->assertEquals("baz", (new Foo())->bar());
}
PHP
  }
  let(:expected_compilation) do
    <<PHP
declare(strict_types=1);

$extra = 2;
class Foo { function bar() { return "baz"; } }

use PHPUnit\\Framework\\TestCase;

final class MumukiSubmissionTestTest extends TestCase {
  public function testFooBarBaz(): void {
    $this->assertEquals("baz", (new Foo())->bar());
  }

}
PHP
  end

  it { expect(compilation).to eq expected_compilation }
end

