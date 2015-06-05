#!/bin/bash

readonly PROGRAM_NAME=$(basename $0)
readonly PROGRAM_LOC=$(readlink -m $(dirname $0))
readonly ARGS="$@"

usage() {
  echo usage: $PROGRAM_NAME LOCAL_PORT REMOTE_PORT REMOTE_HOST
  exit 1
}

create_tunnel() {
  local readonly local_port=$1; shift
  local readonly remote_port=$1; shift
  local readonly remote_host=$1; shift

  ssh -f -N $remote_host -R $remote_port":localhost:"$local_port
}

tunnel_not_present() {
  local readonly remote_port=$1; shift

  ps ax \
    | grep ssh \
    | grep $remote_port \
    | grep -v grep >> /dev/null

  [[ $? -ne 0 ]]
}

maintain_tunnel() {
  local readonly local_port=$1; shift
  local readonly remote_port=$1; shift
  local readonly remote_host=$1; shift

  if tunnel_not_present $remote_port;  then
    create_tunnel $local_port $remote_port $remote_host
  fi
}

is_empty() {
  local readonly string=$1; shift

  [[ -z "$string" ]]
}

main() {
  local readonly local_port=$1; shift
  local readonly remote_port=$1; shift
  local readonly remote_host=$1; shift

  if is_empty $local_port || is_empty $remote_port || is_empty $remote_host
  then
    usage
  fi

  maintain_tunnel $local_port $remote_port $remote_host
}

main
