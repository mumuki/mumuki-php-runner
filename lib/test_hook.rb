class PhpTestHook < Mumukit::Defaults::TestHook
  TEST_NAME = 'MumukiSubmissionTest'
  PASSED_REGEXP = /[✔☢] ([^\n]+)/
  FAILED_REGEXP = /✘ ([^\n]+)\n *\│\n *│ ([^イ]+│ \n   )/

  def run!(request)
    result = request.result[:test]

    unless result.include? TEST_NAME
      return [mask_tempfile_references(result.strip), :errored]
    end

    [to_structured_result(result)]
  end

  def to_structured_result(result)
    passed_tests = result.scan(PASSED_REGEXP).map { |it| to_passed_result it }
    failed_tests = result.scan(FAILED_REGEXP).map { |it| to_failed_result it }.uniq { |it| it.first }

    passed_tests.concat(failed_tests)
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

  def mask_tempfile_references(string)
    string.gsub /\/tmp\/tmp\.\w+/, 'solution.php'
  end
end
