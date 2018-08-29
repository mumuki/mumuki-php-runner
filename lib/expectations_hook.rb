require 'mulang/php'

class PhpExpectationsHook < Mumukit::Templates::MulangExpectationsHook
  include Mumukit::Templates::WithIsolatedEnvironment
  include Mumukit::WithTempfile

  SEPARATOR = '==> JSON dump:'

  include_smells true

  def language
    'Mulang'
  end

  def command_line(filename)
    "php-parse --json-dump #{filename}"
  end

  def compile_content(source)
    output, status = run_get_ast! "<?php\n#{source}"

    if status != :passed || !output.include?(SEPARATOR)
      raise Exception.new("Unable to get Mulang AST - Command failed with status: #{status}")
    end

    json = output.split(SEPARATOR).last
    ast = JSON.parse(json, symbolize_names: true)

    Mulang::PHP.parse(ast)
  rescue => e
    raise Mumukit::CompilationError, e
  end

  def default_smell_exceptions
    LOGIC_SMELLS + FUNCTIONAL_SMELLS + %w(HasWrongCaseBindings)
  end

  def domain_language
    {
      minimumIdentifierSize: 3,
      jargon: []
    }
  end

  private

  def run_get_ast!(source)
    file = write_tempfile! source
    run_file! file
  end
end
