#/bin/bash 

SHA=''

function build() {
  SHA=$(docker build `pwd`/../ | grep "^Successfully built" | awk '{ print $3 }')
  echo "Testing image with sha ${SHA}"
}

function runtest() {
  title=$1
  cmd=$2
  expectedexit=$3
  greptext=$4

  #Colors
  YELLOW='\033[0;33m'
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  NC='\033[0m'

  echo "${YELLOW}${title}${NC} should exit ${YELLOW}${expectedexit}${NC}... \c"

  output=$($cmd 2>&1)
  exitcode=$?
  
  if [ "$greptext" != "" ]; then
    echo $output | grep -q "$greptext"

    is_found=$?
    notfound=1

    if [ "$is_found" -eq "$notfound" ]; then
      echo "${RED}FAIL"
      echo "String not found: ${greptext}"
      echo "${NC}"
      exit 1
    fi
  fi

  if [ "$exitcode" -eq "$expectedexit" ]; then
    echo "${GREEN}PASS${NC}"
  else
    echo "${RED}FAIL"
    echo $output
    echo "${NC}"
    exit 1
  fi
}

build

runtest 'Puppetfile with bad syntax' "docker run -v `pwd`/control-repo/badsyntax:/repo ${SHA} rake -f /Rakefile r10k:syntax" 1 'Puppetfile syntax check failed';
runtest 'Puppetfile with good syntax' "docker run -v `pwd`/control-repo/goodsyntax:/repo ${SHA} rake -f /Rakefile r10k:syntax" 0 'Syntax OK';

runtest 'Templates with bad syntax' "docker run -v `pwd`/control-repo/badsyntax:/repo ${SHA} rake -f /Rakefile syntax:templates" 1 "Syntax error at '' at site/profile/templates/bad_template.epp:2:23";
runtest 'Templates with good syntax' "docker run -v `pwd`/control-repo/goodsyntax:/repo ${SHA} rake -f /Rakefile syntax:templates" 0 "";

runtest 'Manifests with bad syntax' "docker run -v `pwd`/control-repo/badsyntax:/repo ${SHA} rake -f /Rakefile syntax:manifests" 1 "Could not parse for environment \*root\*: Syntax error at 'SYNTAX' at /repo/site/profile/manifests/common.pp:5:12";
runtest 'Manifests with good syntax' "docker run -v `pwd`/control-repo/goodsyntax:/repo ${SHA} rake -f /Rakefile syntax:manifests" 0 '';

runtest 'Hiera with bad syntax' "docker run -v `pwd`/control-repo/badsyntax:/repo ${SHA} rake -f /Rakefile syntax:hiera" 1 "ERROR: Failed to parse data/common.yaml: (data/common.yaml): could not find expected ':' while scanning a simple key at line 4 column 1";
runtest 'Hiera with good syntax' "docker run -v `pwd`/control-repo/goodsyntax:/repo ${SHA} rake -f /Rakefile syntax:hiera" 0 '';
