require 'active_support/all'

require 'mumukit/bridge'

describe 'runner' do
  let(:bridge) { Mumukit::Bridge::Runner.new('http://localhost:4567') }
  before(:all) do
    @pid = Process.spawn 'rackup -p 4567', err: '/dev/null'
    sleep 3
  end
  after(:all) { Process.kill 'TERM', @pid }

  let(:test) do
    <<PHP
public function testFooBarBaz(): void {
  $this->assertEquals("baz", (new Foo())->bar());
}
PHP
  end

  let(:ok_content) do
    <<PHP
class Foo {
  function bar() {
    return "baz";
  }
}
PHP
  end

  let(:not_ok_content) do
    <<PHP
class Foo {
  function bar() {
    return "bazaasdsad";
  }
}
PHP
  end

  let(:broken_content) do
    <<PHP
class Foo {[!Ñ[!]"]!"]
  function bar() {
    return "bazasfsalskasdpllllaasdsad";
  }
}
PHP
  end

  it 'answers a valid hash when query is ok' do
    response = bridge.run_query!(extra: "$something = 2;",
                                 content: 'function asd($a) { return $a . "asd"; }',
                                 query: 'asd($something * 3)')
    expect(response).to eq(status: :passed, result: "6asd")
  end

  it 'answers a valid hash when submission is ok' do
    response = bridge.run_tests!(test: test,
                                 extra: '',
                                 content: ok_content)

    expect(response).to eq(response_type: :structured,
                           test_results: [{title: 'Foo bar baz', status: :passed, result: ''}],
                           status: :passed,
                           feedback: '',
                           expectation_results: [],
                           result: '')
  end

  it 'answers a valid hash when submission is not ok' do
    response = bridge.run_tests!(test: test,
                                 extra: '',
                                 content: not_ok_content,
                                 expectations: [])

    expect(response).to eq(response_type: :structured,
                           test_results: [{title: 'Foo bar baz', status: :failed, result: (<<RESULT
Failed asserting that two strings are equal.
   │ --- Expected
   │ +++ Actual
   │ @@ @@
   │ -'baz'
   │ +'bazaasdsad'
RESULT
).chop}],
                           status: :failed,
                           feedback: '',
                           expectation_results: [],
                           result: '')
  end


  it 'answers a valid hash when submission is broken' do
    response = bridge.run_tests!(test: test,
                                 extra: '',
                                 content: "#{broken_content}",
                                 expectations: [])

    expect(response).to eq(response_type: :unstructured,
                           test_results: [],
                           status: :errored,
                           feedback: '',
                           expectation_results: [],
                           result: "PHP Parse error:  syntax error, unexpected '[', expecting function (T_FUNCTION) or const (T_CONST) in solution.php on line 5\n")
  end
end
