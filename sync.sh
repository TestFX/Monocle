#!/usr/bin/env bash

# Usage info
show_help() {
cat << EOF
Usage: ${0##*/} [-hf]
Syncs the TestFX Monocle repository with upstream.

    -h          display this help and exit
EOF
}

red=$(tput setaf 1)
green=$(tput setaf 2)
reset=$(tput sgr0)

# Checks if a program is in the user's PATH, and is executable.
check_executable() {
  test -x "$(command -v "${1}")"
}

require_executable() {
  if ! check_executable "${1}"; then
    >&2 echo "${red}${BASENAME}: '${1}' not found in PATH or not executable.${reset}"
    exit 1
  fi
}

find_git_remote() {
  git remote -v \
    | awk '$2 ~ /github.com[:\/]testfx\/monocle/ && $3 == "(fetch)" {print $1; exit}'
}

submit_pr() {
  version=$1
  build=$2
  sha=$3
  hub=$4
  read -p "Would you like to open a PR for ${version}-${build}? " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    wget --quiet --output-document="$sha"-src.tar.gz http://hg.openjdk.java.net/openjfx/8u-dev/rt/archive/"$sha".tar.gz/modules/graphics/src/main/java/com/sun/glass/ui/monocle/
    wget --quiet --output-document="$sha"-res.tar.gz http://hg.openjdk.java.net/openjfx/8u-dev/rt/archive/"$sha".tar.gz/modules/graphics/src/main/resources/com/sun/glass/ui/monocle/
    tar -xf "$sha"-src.tar.gz --strip-components 3
    rm "$sha"-src.tar.gz
    tar -xf "$sha"-res.tar.gz --strip-components 3
    rm "$sha"-res.tar.gz
    remote="$(find_git_remote)"
    printf "Opening PR to %s for %s\\n" "$remote" "$version"-"$build"
    printf "Summary of changes:\\n"
    git --no-pager diff --stat
    git fetch "$remote" master
    git checkout -b "$version"-"$build" "$remote"/master
    git add -A
    git reset -- .sync
    commit_msg="Update Monocle to ${version}-${build} (${sha})."
    git commit -m "$commit_msg"
    git push origin "$version"-"$build"
    "${hub}" pull-request -m "$version"-"$build"
    git checkout master
  else
    echo "Skipping ${version}-${build}."
  fi
}

hub='hub'
pup='pup'

install_prereqs() {
  if ! check_executable hub; then
    echo "Downloading hub (command-line Github tool)"
    wget --quiet --output-document=hub.tgz https://github.com/github/hub/releases/download/v2.3.0-pre8/hub-linux-amd64-2.3.0-pre8.tgz
    if [[ $(sha256sum hub.tgz | head -c 64) != "9332c78b6a2ee66767836452019b9eafc048cf65871c0c5d2a0fa51ce3a90142" ]]; then
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

  if ! check_executable pup; then
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

  for key in "${!tags[@]}"
  do
    version=$(echo "$key" | cut -f1 -d-)
    build=$(echo "$key" | cut -f2 -d-)
    if [[ -z "${highest_builds[${version}]}" ]]; then
      # Have not yet seen a build for this version, so add this one
      highest_builds[$version]=$build
    else
      # We have seen a build for this version, see if this one is higher
      if [ "${build:1}" -gt "${highest_builds[$version]:1}" ]; then
        highest_builds[$version]=$build
      fi
    fi
  done

  read -a monocle_tags <<<"$(git tag -l | xargs echo -n)"
  for monocle_tag in "${monocle_tags[@]}"
  do
    if [[ $monocle_tag =~ "-" ]]; then
      version=$(echo "$monocle_tag" | cut -f1 -d-)
      build=$(echo "$monocle_tag" | cut -f2 -d-)
      if [[ ! -z "${highest_builds[${version}]}" ]]; then
        if [ "${highest_builds[${version}]}" == "$build" ]; then
          # We can skip this version, as the highest build is already a tag
          # in the upstream monocle repository.
          printf "Version %s already has the highest build %s\\n" "$version" "$build"
        else
          # There is a newer build available
          printf "The latest build for version %s is %s in upstream, but there is a newer build %s\\n" "$version" "$build" "${highest_builds[${version}]}"
          submit_pr "$version" "${highest_builds[${version}]}" "${tags["$version"-"${highest_builds[$version]}"]}" "$hub"
          highest_builds[${version}]=''
        fi
      fi
  fi
  done
  for key in "${!highest_builds[@]}"
  do
    if [[ ! -z "${highest_builds[$key]}" ]]; then
      submit_pr "$key" "${highest_builds[${key}]}" "${tags["$key"-"${highest_builds[$key]}"]}" "$hub"
    fi
  done
}

require_executable git
require_executable curl
require_executable wget
require_executable unzip
install_prereqs

fetch_highest_builds "http://hg.openjdk.java.net/openjfx/8u-dev/rt/tags" "3a7f004c4995"
fetch_highest_builds "http://hg.openjdk.java.net/openjfx/9-dev/rt/tags" "dc2bda380efe"
