class PhpQueryHook < PhpFileHook
  def command_line(filename)
    "php #{filename}"
  end

  def compile_file_content(req)
    <<EOF
<?php
#{req.content}
#{req.extra}

echo #{req.query};
EOF
  end
end
