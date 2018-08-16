class PhpFileHook < Mumukit::Templates::FileHook
  isolated true

  def tempfile_extension
    '.php'
  end
end
