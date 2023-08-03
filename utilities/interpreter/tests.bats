

thing=$(shell_identity)
# echo "EXIT_STATUS: $?"
echo "shell_identity : $thing"
echo '========================'
retval=$(is_valid_shell "bxash")
echo "EXIT_STATUS: $?"
echo "retval :: ${retval}"
echo '===-------==='
thing=$(is_shell "ZSH")
echo "EXIT_STATUS: $?"
echo "is_shell : ZSH : $thing"
echo '===-------==='
thing=$(is_bash "bash")
echo "EXIT_STATUS: $?"
echo "is_bash : bash : $thing"
echo '===-------==='
thing=$(is_zsh)
echo "EXIT_STATUS: $?"
echo "is_zsh : ZSH : $thing"
echo '===-------==='
