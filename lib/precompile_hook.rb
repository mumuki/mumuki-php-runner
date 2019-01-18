class PhpPrecompileHook < PhpFileHook
  BATCH_SEPARATOR = "\n/* ---Mumuki-Batch-Separator--- */\n"
  RESULTS_SEPARATOR = "\n/* ---Mumuki-Results-Separator--- */\n"

  def command_line(*filenames)
    "run-tests-and-get-ast #{filenames.join(' ')}"
  end

  def compile(request)
    return request unless request[:query].nil?

    file = super request
    struct request.to_h.merge result: run!(file)
  end

  def compile_file_content(request)
    test_content = compile_test_content request
    ast_content = compile_ast_content request

    if has_files?(request)
      test_content.merge('submission_ast.json' => ast_content)
    else
      test_content + BATCH_SEPARATOR + ast_content
    end
  end

  def post_process_file(_file, result, status)
    parts = result.split RESULTS_SEPARATOR

    { test: parts.first, ast: parts.last }
  end

  def compile_test_content(request)
    test = <<-EOF
<?php
declare(strict_types=1);

#{request.extra}
#{has_files?(request) ? '' : request.content}

use PHPUnit\\Framework\\TestCase;

final class #{PhpTestHook::TEST_NAME}Test extends TestCase {
#{request.test.lines.map {|it| '  ' + it}.join}
}
    EOF

    has_files?(request) ?
      files_of(request).merge('submission_test.php' => test) :
      test
  end

  def compile_ast_content(request)
    "<?php\n#{request[:content]}"
  end
end
