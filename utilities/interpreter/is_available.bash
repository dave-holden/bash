

is_available() {
  echo "is_available : $@"
  found=false
  for i in zsh bash 
  do 
    echo "is_available :: I : $i"
    # if [ "$i" = "$str" ] ; then
    if "/usr/bin/env ${i}" "$@"; 
    then
      echo "is_available :: FOUND ${i}"
      # echo "eq ${i} == ${str}"
      found=true
      break
    else
      echo "is_available :: NOT FOUND ${i}"
    fi
    echo "NOT FOUND"
  done
  # echo $found

  return $([ $found = true ] &&  echo 0 || echo 1)
}
