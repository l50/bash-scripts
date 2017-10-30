if [[ `uname` != 'Darwin' ]]
then
  os=`cat /etc/os-release | perl -n -e'while(/^ID=(.*)/g) {print "$1\n"}'`
  if [[ $os == 'kali' ]]
  then
    echo 'kali'
  elif [[ $os == 'ubuntu' ]]
  then
  echo 'ubuntu'
  fi
else
  echo 'OS X'
fi
