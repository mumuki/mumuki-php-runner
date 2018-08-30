#!/bin/bash

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
echo "/* ---Mumuki-Results-Separator--- */"
php-parse --json-dump $tmp_ast_code

rm $tmp_test_code
rm $tmp_ast_code
