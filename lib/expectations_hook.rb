require 'mulang/php'

class PhpExpectationsHook < Mumukit::Templates::MulangExpectationsHook
  SEPARATOR = '==> JSON dump:'

  include_smells true

  def language
    'Mulang'
  end

  def mulang_code(request)
    result = request.result[:ast]

    Mulang::Code.new(mulang_language, to_mulang_ast(result))
  end

  def original_language
    'Php'
  end

  def to_mulang_ast(output)
    unless output.include? SEPARATOR
      return ['Unable to get Mulang AST - Command failed!', :errored]
    end

    json = output.split(SEPARATOR).last
    ast = JSON.parse json, symbolize_names: true

    Mulang::PHP.parse(ast)
  rescue => e
    raise Mumukit::CompilationError, e
  end

  def default_smell_exceptions
    LOGIC_SMELLS + FUNCTIONAL_SMELLS + OBJECT_ORIENTED_SMELLS
  end

  def domain_language
    {
      minimumIdentifierSize: 3,
      jargon: []
    }
  end
end
