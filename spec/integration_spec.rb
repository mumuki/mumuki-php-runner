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
    response = bridge.run_query!(extra: '$something = 2;',
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
                                 expectations: [{ binding: '*', inspection: 'DeclaresClass:Foo' }])

    expect(response).to eq(response_type: :unstructured,
                           test_results: [],
                           status: :errored,
                           feedback: '',
                           expectation_results: [],
                           result: "Parse error: syntax error, unexpected '[', expecting function (T_FUNCTION) or const (T_CONST) in solution.php on line 5")
  end

  it 'supports testing SQLite with PDO' do
    response = bridge.run_tests!(test: (<<TEST
public function testDbHasTheRightData(): void {
  global $memory_db;

  // Retrieve one row from messages table
  $query = $memory_db->prepare('SELECT * FROM messages LIMIT 1');
  $query->execute();
  $data = $query->fetch();

  // Check the results
  $this->assertEquals("Hello!", $data['title']);
  $this->assertEquals("Just testing...", $data['message']);
}
TEST
                                 ),
                                 extra: (<<EXTRA
// Create new database in memory
$memory_db = new PDO('sqlite::memory:');

// Set error mode to exceptions
$memory_db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

// Create a messages table
$memory_db->exec("CREATE TABLE messages (
                  id INTEGER PRIMARY KEY, 
                  title TEXT, 
                  message TEXT)");
EXTRA
                                 ),
                                 content: (<<CONTENT
// Array with some data to insert to database             
$messages = array(
              array('title' => 'Hello!', 'message' => 'Just testing...'),
              array('title' => 'Hello again!', 'message' => 'More testing...'),
              array('title' => 'Hi!', 'message' => 'SQLite3 is cool...')
            );

// Prepare INSERT statement to SQLite3
$insert = "INSERT INTO messages (id, title, message) VALUES (:id, :title, :message)";
$stmt = $memory_db->prepare($insert);

// Bind parameters to statement variables
$stmt->bindParam(':title', $title);
$stmt->bindParam(':message', $message);

// Loop thru all messages and execute prepared insert statement
foreach ($messages as $m) {
  // Set values to bound variables
  $title = $m['title'];
  $message = $m['message'];

  // Execute statement
  $stmt->execute();
}
CONTENT
                                 ))

    expect(response).to eq(response_type: :structured,
                           test_results: [{title: 'Db has the right data', status: :passed, result: ''}],
                           status: :passed,
                           feedback: '',
                           expectation_results: [],
                           result: '')
  end

  context 'with expectations' do
    it 'answers a valid hash when it passes all the expectations' do
      response = bridge.run_tests!(test: test,
                                   expectations: [{ binding: '*', inspection: 'DeclaresClass:Foo' }],
                                   extra: '',
                                   content: ok_content)

      expect(response).to eq(response_type: :structured,
                             test_results: [{title: 'Foo bar baz', status: :passed, result: ''}],
                             status: :passed,
                             feedback: '',
                             expectation_results: [{binding: '*', inspection: 'DeclaresClass:Foo', result: :passed}],
                             result: '')
    end

    it 'answers a valid hash when there are failing expectations' do
      response = bridge.run_tests!(test: test,
                                   expectations: [{ binding: '*', inspection: 'Not:DeclaresClass:Foo' }],
                                   extra: '',
                                   content: ok_content)

      expect(response).to eq(response_type: :structured,
                             test_results: [{title: 'Foo bar baz', status: :passed, result: ''}],
                             status: :passed_with_warnings,
                             feedback: '',
                             expectation_results: [{binding: '*', inspection: 'Not:DeclaresClass:Foo', result: :failed}],
                             result: '')
    end

    it 'answers a valid hash when there are mixed passing and failing expectations' do
      response = bridge.run_tests!(test: test,
                                   expectations: [
                                     { binding: '*', inspection: 'DeclaresClass:Foo' },
                                     { binding: 'Foo', inspection: 'DeclaresMethod:bar' },
                                     { binding: 'Foo', inspection: 'DeclaresMethod:ASFJASFJASF' },
                                   ],
                                   extra: '',
                                   content: ok_content)

      expect(response).to eq(response_type: :structured,
                             test_results: [{title: 'Foo bar baz', status: :passed, result: ''}],
                             status: :passed_with_warnings,
                             feedback: '',
                             expectation_results: [
                               { binding: '*', inspection: 'DeclaresClass:Foo', result: :passed },
                               { binding: 'Foo', inspection: 'DeclaresMethod:bar', result: :passed },
                               { binding: 'Foo', inspection: 'DeclaresMethod:ASFJASFJASF', result: :failed },
                             ],
                             result: '')
    end

    context 'with multiple files' do
      let (:response) { bridge.run_tests!(test: (<<TEST
protected function setUp() {
  require('foo.php');
  require('foobar.php');
}

public function testFooBarBaz(): void {
  $this->assertEquals("baz", (new Foo())->bar());
  $this->assertEquals("zbaz", (new FooBar())->barba());
}
TEST
      ),
                                   extra: nil,
                                   content: content,
                                   expectations: [
                                     { binding: 'Foo', inspection: 'DeclaresMethod:bar' },
                                     { binding: 'FooBar', inspection: 'Uses:Foo' },
                                     { binding: 'FooBar', inspection: 'DeclaresMethod:barba' },
                                     { binding: 'FooBar', inspection: 'DeclaresMethod:barbarroja' }
                                   ]
      )}

      context 'with passing tests and failed expectations' do
        let (:content) { (<<CONTENT
/*<foo.php#*/
class Foo {
  public function bar() {
    return "baz";
  }
} 
/*#foo.php>*/
/*<foobar.php#*/
class FooBar {
  public function barba() {
    return "z" . (new Foo())->bar();
  }
} 
/*#foobar.php>*/
CONTENT
        )}

        it { expect(response).to eq(response_type: :structured,
                                 test_results: [
                                   {title: 'Foo bar baz', status: :passed, result: ''}
                                 ],
                                 status: :passed_with_warnings,
                                 feedback: '',
                                 expectation_results: [
                                   { binding: 'Foo', inspection: 'DeclaresMethod:bar', result: :passed },
                                   { binding: 'FooBar', inspection: 'Uses:Foo', result: :passed },
                                   { binding: 'FooBar', inspection: 'DeclaresMethod:barba', result: :passed },
                                   { binding: 'FooBar', inspection: 'DeclaresMethod:barbarroja', result: :failed }
                                 ],
                                 result: '') }
      end
    end
  end
end
