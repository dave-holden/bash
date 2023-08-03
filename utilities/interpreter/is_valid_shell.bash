


is_valid_shell() {
  str="$1"
  found=false
  for i in bash zsh
  do 
    echo "$i === $str"
    if [ "$i" = "$str" ] ; then
      # echo "eq ${i} == ${str}"
      found=trueUTI
    break
    fi
  done
  echo $found

  return $([ $found = true ] &&  echo 0 || echo 1)
}
