<?php

require 'vendor/autoload.php';

use PhpParser\Error;
use PhpParser\ParserFactory;

$filename = $argv[1];
$file = fopen($filename, "r") or die("Unable to open file!");
$code = fread($file, filesize($filename));

$parser = (new ParserFactory)->create(ParserFactory::PREFER_PHP7);
try {
  $ast = $parser->parse($code);
} catch (Error $error) {
  echo "Parse error: {$error->getMessage()}\n";
  exit(1);
}

echo json_encode($ast, JSON_PRETTY_PRINT), "\n";
