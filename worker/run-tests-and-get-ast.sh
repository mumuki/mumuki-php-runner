#!/bin/bash

function print_separator() {
  echo "/* ---Mumuki-Results-Separator--- */"
}

files_count="$#"
if [ "$files_count" -gt "1" ]; then
  # -----------
  # MULTI FILE
  # -----------

  dir_name=$(dirname "$1")
  cd "$dir_name"

  phpab --output autoload.php .
  phpunit --bootstrap autoload.php --testdox mumukisubmissiontest
  print_separator
  php-parse --json-dump submission_ast.json
else
  # -----------
  # SINGLE FILE
  # -----------

  tmp_test_code=$(mktemp)
  tmp_ast_code=$(mktemp)

  batch=$(cat $1)
  delimiter="/* ---Mumuki-Batch-Separator--- */"

  # ---
  a=()
  i=0
  while read -r line
  do
    a[i]="${a[i]}${line}"$'\n'
    if [ "$line" == "$delimiter" ]
    then
      let ++i
    fi
  done <<< "$batch"
  # ---

  test_code=$(echo "${a[0]}" | head -n -2)
  ast_code="${a[1]}"

  echo "$test_code" > $tmp_test_code
  echo "$ast_code" > $tmp_ast_code

  # ----------

  phpunit --testdox $tmp_test_code
  print_separator
  php-parse --json-dump $tmp_ast_code

  rm $tmp_test_code
  rm $tmp_ast_code
fi
