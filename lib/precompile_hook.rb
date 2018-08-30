class PhpPrecompileHook < PhpFileHook
  BATCH_SEPARATOR = "\n/* ---Mumuki-Batch-Separator--- */\n"
  RESULTS_SEPARATOR = "\n/* ---Mumuki-Results-Separator--- */\n"

  def command_line(filename)
    "run-tests-and-get-ast #{filename}"
  end

  def compile(request)
    return request unless request[:query].nil?

    file = super request
    struct request.to_h.merge result: run!(file)
  end

  def compile_file_content(request)
    compile_test_content(request) + BATCH_SEPARATOR + compile_ast_content(request)
  end

  def post_process_file(_file, result, status)
    parts = result.split RESULTS_SEPARATOR

    { test: parts.first, ast: parts.last }
  end

  private

  def compile_test_content(request)
    <<-EOF
<?php
declare(strict_types=1);

#{request.extra}
    #{request.content}

use PHPUnit\\Framework\\TestCase;

final class #{PhpTestHook::TEST_NAME}Test extends TestCase {
#{request.test.lines.map {|it| '  ' + it}.join}
}
    EOF
  end

  def compile_ast_content(request)
    "<?php\n#{request[:content]}"
  end
end
