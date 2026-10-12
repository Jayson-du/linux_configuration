#!/usr/bin/bash
set -e

targetpath=$1

message=$(cat << 'EOF'
#!/usr/bin/bash
set -e

path="$targetpath"

ToolFile=(
  # default file
  "gitadd.sh"
)

function getTheTrueFile() {
  local file="${path}"/$1
  echo "$file"
}

if [ $1 == "add" ]; then
  echo ">> git add"
  for file in "${ToolFile[@]}"; do
    git add "$(getTheTrueFile "$file")"
  done
elif [ $1 == "restore" ]; then
  echo ">> git restore"
  for file in "${ToolFile[@]}"; do
    git restore --staged "$(getTheTrueFile "$file")"
  done
fi
EOF
)

message="${message//\$targetpath/$targetpath}"

touch $1/gittool.sh && chmod +x $1/gittool.sh && echo "$message" > $1/gittool.sh