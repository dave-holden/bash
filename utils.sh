if command -v source; then
  echo "Source command found"
  source ./core/shell_env.sh
  source ./core/spinners.sh
  source ./formatting/colours.sh
  source ./formatting/output.sh
else
  echo "Source command Not found"
  . ./core/shell_env.sh
  . ./core/spinners.sh
  . ./formatting/colours.sh
  . ./formatting/output.sh
fi
echo