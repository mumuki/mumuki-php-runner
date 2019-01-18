class PhpFileHook < Mumukit::Templates::MultiFileHook
  isolated true

  def tempfile_extension
    '.php'
  end
end
