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
end
