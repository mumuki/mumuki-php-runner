class PhpPrecompileHook < PhpFileHook
  BATCH_SEPARATOR = "\n/* ---Mumuki-Batch-Separator--- */\n"
  RESULTS_SEPARATOR = "\n/* ---Mumuki-Results-Separator--- */\n"

  def command_line(*filenames)
    "run-tests-and-get-ast #{filenames.join(' ')}"
  end

  def compile(request)
    return request unless request[:query].nil?

    files = super request
    struct request.to_h.merge result: run!(files)
  end

  def compile_file_content(request)
    test_content = compile_test_content request

    if has_files?(request)
      ast_content = request.content.values.join("\n")
      add_php_tags(test_content).merge('submission_ast.json' => add_php_tag(ast_content))
    else
      add_php_tag(test_content) + BATCH_SEPARATOR + add_php_tag(request.content)
    end
  end

  def post_process_file(_file, result, status)
    parts = result.split RESULTS_SEPARATOR

    { test: parts.first, ast: parts.last }
  end

  private

  def compile_test_content(request)
    test = <<-EOF
declare(strict_types=1);

#{request.extra}
#{has_files?(request) ? '' : request.content}

use PHPUnit\\Framework\\TestCase;

final class #{PhpTestHook::TEST_NAME}Test extends TestCase {
#{request.test.lines.map {|it| '  ' + it}.join}
}
    EOF

    has_files?(request) ?
      files_of(request).merge("#{PhpTestHook::TEST_NAME.downcase}.php" => test) :
      test
  end

  def add_php_tags(files)
    Hash[files.map{|name, content| [name, add_php_tag(content)] } ]
  end

  def add_php_tag(content)
    "<?php\n#{content}"
  end
end
