class PhpTestHook < PhpFileHook
  structured true

  TEST_NAME = 'AAAMumukiTestCaseAAA'
  PASSED_REGEXP = /[✔☢] ([^\n]+)/
  FAILED_REGEXP = /✘ ([^\n]+)\n *\│\n *│ ([^イ]+│ \n   )/

  def command_line(filename)
    "phpunit --testdox #{filename}"
  end

  def post_process_file(file, result, status)
    return [result, :errored] unless result.include? TEST_NAME

    super file, result, status
  end

  def to_structured_result(result)
    passed_tests = result.scan(PASSED_REGEXP).map { |it| to_passed_result it }
    failed_tests = result.scan(FAILED_REGEXP).map { |it| to_failed_result it }.uniq { |it| it.first }

    passed_tests.concat(failed_tests)
  end

  def compile_file_content(req)
    <<-EOF
<?php
declare(strict_types=1);

#{req.extra}
#{req.content}

use PHPUnit\\Framework\\TestCase;

final class #{TEST_NAME}Test extends TestCase {
#{req.test.lines.map {|it| '  ' + it}.join}
}
EOF
  end

  private

  def to_passed_result(regexp_groups)
    [regexp_groups.first, 'passed', '']
  end

  def to_failed_result(regexp_groups)
    reason_lines = regexp_groups.last.split "\n"
    reason = reason_lines.take(reason_lines.count - 2).join "\n"

    [regexp_groups.first, 'failed', reason]
  end
end
