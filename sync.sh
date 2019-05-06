#!/usr/bin/env bash

# Usage info
show_help() {
cat << EOF
Usage: ${0##*/} [-h]
Syncs the TestFX Monocle repository with upstream.

    -h          display this help and exit
EOF
}

if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
  show_help
  exit 0
fi

red=$(tput setaf 1)
green=$(tput setaf 2)
reset=$(tput sgr0)
separator='+'

require_executable() {
  if ! check_executable "${1}"; then
    >&2 echo "${red}${BASENAME}: '${1}' not found in PATH or not executable.${reset}"
    exit 1
  fi
}

find_git_remote() {
  git remote -v \
    | awk 'tolower($2) ~ /github.com[:\/]testfx\/monocle/ && $3 == "(fetch)" {print $1; exit}'
}

submit_pr() {
  version=$1
  build=$2
  sha=$3
  hub=$4
  branch_name="${version}${separator}${build}"
  read -p "Would you like to open a PR for ${branch_name}? " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    major_version=${version:0:2}
    wget --quiet --output-document="$sha"-src.tar.gz http://hg.openjdk.java.net/openjfx/"$major_version"-dev/rt/archive/"$sha".tar.gz/modules/javafx.graphics/src/main/java/com/sun/glass/ui/monocle/
    wget --quiet --output-document="$sha"-res.tar.gz http://hg.openjdk.java.net/openjfx/"$major_version"-dev/rt/archive/"$sha".tar.gz/modules/javafx.graphics/src/main/resources/com/sun/glass/ui/monocle/
    tar -xf "$sha"-src.tar.gz --strip-components 3
    rm "$sha"-src.tar.gz
    tar -xf "$sha"-res.tar.gz --strip-components 3
    rm "$sha"-res.tar.gz
    remote="$(find_git_remote)"
    if [[ -z "$remote" ]]; then
      echo "${red}✘ Error (git): Could not find remote with URL matching github.com/testfx/monocle!${reset}" >&2
      printf "You can add the upstream TestFX repository with 'git remote add upstream https://github.com/testfx/monocle\\n"
      exit
    fi
    printf "Opening PR to %s for %s\\n" "$remote" "$branch_name"
    printf "Summary of changes:\\n"
    git --no-pager diff --stat
    git fetch "$remote" master
    git checkout -b "$branch_name" "$remote"/master
    git add -A
    git reset -- .sync
    commit_msg="Update Monocle to ${branch_name} (${sha})."
    git commit -m "$commit_msg"
    git push origin "$branch_name"
    "${hub}" pull-request -m "$branch_name"
    git checkout master
  else
    echo "Skipping ${branch_name}."
  fi
}

hub='hub'
pup='pup'

# Checks if a program is in the user's PATH, and is executable.
check_executable() {
  local=${2:-false}
  if [ "$local" = true ]; then
    if [[ "$(command -v "${1}")" ]]; then
      true
    elif [[ "$(command -v .sync/"$1")" ]]; then
      eval "$1"="'./.sync/$1'"
      true
    else
      false
    fi
  else
    test -x "$(command -v "${1}")"
  fi
}

install_prereqs() {
  if ! check_executable hub true; then
    echo "Downloading hub (command-line Github tool)"
    hub_ver="2.11.2"
    hub_sha="7e7a57f5323d3d7d9637cad8ea8f584d7db67e040201d6d88275910f8e235a80"
    wget --quiet --output-document=hub.tgz https://github.com/github/hub/releases/download/v${hub_ver}/hub-linux-amd64-${hub_ver}.tgz
    if [[ $(sha256sum hub.tgz | head -c 64) != "${hub_sha}" ]]; then
      echo "${red}✘ Error (integrity): hub release download had bad checksum${reset}" >&2
      exit
    fi
    mkdir hub-dir
    tar -xf hub.tgz -C hub-dir --strip-components 1
    rm hub.tgz
    mkdir -p .sync
    cp ./hub-dir/bin/hub .sync/
    rm -r hub-dir
    hub='./.sync/hub'
  fi

  if ! check_executable pup true; then
    echo "Downloading pup (command-line HTML parser)"
    wget --quiet --output-document=pup.zip https://github.com/ericchiang/pup/releases/download/v0.4.0/pup_v0.4.0_linux_amd64.zip
    if [[ $(sha256sum pup.zip | head -c 64) != "ec3d29e9fb375b87ac492c8b546ad6be84b0c0b49dab7ff4c6b582eac71ba01c" ]]; then
      echo "${red}✘ Error (integrity): pup release download had bad checksum${reset}" >&2
      exit
    fi
    unzip -qq pup.zip
    mkdir -p .sync
    mv ./pup .sync/
    rm pup.zip
    pup='./.sync/pup'
  fi
}

# https://stackoverflow.com/questions/4023830/how-to-compare-two-strings-in-dot-separated-version-format-in-bash
vercmp() {
    version1=$1 version2=$2 condition=$3
    IFS=. v1_array=($version1) v2_array=($version2)
    v1=$((v1_array[0] * 100 + v1_array[1] * 10 + v1_array[2]))
    v2=$((v2_array[0] * 100 + v2_array[1] * 10 + v2_array[2]))
    diff=$((v2 - v1))
    [[ $condition = '='  ]] && ((diff == 0)) && return 0
    [[ $condition = '!=' ]] && ((diff != 0)) && return 0
    [[ $condition = '<'  ]] && ((diff >  0)) && return 0
    [[ $condition = '<=' ]] && ((diff >= 0)) && return 0
    [[ $condition = '>'  ]] && ((diff <  0)) && return 0
    [[ $condition = '>=' ]] && ((diff <= 0)) && return 0
    return 1
}

fetch_highest_builds() {
  tag_url=$1
  start_hash=$2
  raw_tags=$(curl -s "${tag_url}" | ${pup} '.tagEntry text{}' | sed "/$start_hash/q" | xargs echo -n)
  read -a raw <<< "$raw_tags"
  declare -A tags

  for (( i=0; i<${#raw[@]}; i+=2 )); do
    if [ ! "${raw[i]}" == "tip" ]; then
      tags[${raw[i]}]=${raw[i+1]}
    fi
  done

  declare -A highest_builds
  declare -A highest_version_for_major

  for key in "${!tags[@]}"
  do
    # Version is in form "12.x.y+z" so:
    major_version=${key:0:2}
    full_version=$(echo $key | cut -f1 -d$separator)
    if [[ -z "${highest_version_for_major[${major_version}]}" ]]; then
      # Have not yet seen a full version for this major version, so add this one
      highest_version_for_major[$major_version]=$full_version
    elif [[ $(vercmp $full_version "${highest_version_for_major[${major_version}]}" '>') -eq 0 ]]; then
      # We have already seen a full version for this major version but the current one is newer, so replace old value
      highest_version_for_major[$major_version]=$full_version
    fi

    for major_ver in "${!highest_version_for_major[@]}"
    do
      if [[ $key =~ ^$highest_version_for_major[$major_ver] ]]; then
        # This is a build for the highest full version for this major version
        # Get numbers after + character for build
        build=$(echo "$key" | cut -f2 -d$separator)
        if [[ -z "${highest_builds[${full_version}]}" ]]; then
          # Have not yet seen a build for this version, so add this one
          highest_builds[$major_version]=$build
        elif [ "${build}" -gt "${highest_builds[$full_version]}" ]; then
          # We have already seen a build for this version but the current one is higher, so replace old value
          highest_builds[$major_version]=$build
        fi
      fi
    done
  done

  read -a monocle_tags <<<"$(git tag -l | xargs echo -n)"
  for major_version in "${!highest_builds[@]}"
  do
    highest_ver="${highest_version_for_major[${major_version}]}"
    if [[ -n "${highest_builds[$major_version]}" ]]; then
      for monocle_tag in "${monocle_tags[@]}"
      do
        if [[ $monocle_tag =~ ^v?$highest_version_for_major[$major_ver]$separator${highest_builds[${major_version}]}]$ ]]; then
          # Skip this one as it is already in upstream.
          continue
        fi
      done
      submit_pr "$highest_ver" "${highest_builds[${major_version}]}" "${tags["$highest_ver""$separator""${highest_builds[$major_version]}"]}" "$hub"
    fi
  done
}

require_executable git
require_executable curl
require_executable wget
require_executable unzip
install_prereqs

jdk=11
temp=11
while : ; do
  response=$(curl --write-out %{http_code} --silent --output /dev/null http://hg.openjdk.java.net/openjfx/${temp}-dev/rt/tags)

  if [[ "$response" -ne 404 ]] ; then
    jdk=$temp
  else
    break
  fi
  temp=$((temp + 1))
done

# Highest JDK is now $jdk
fetch_highest_builds "http://hg.openjdk.java.net/openjfx/${jdk}-dev/rt/tags" "284d06bb1364"
