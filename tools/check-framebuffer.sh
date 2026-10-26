#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
out="${1:-build/framebuffer-regression}"
test ! -e "$out"
mkdir -p "$out"
"${JAVA_HOME:?Set JAVA_HOME to JDK21 or newer}/bin/javac" --release 21 -d "$out" \
  src/main/java/com/sun/glass/ui/monocle/Framebuffer.java \
  src/test/java/com/sun/glass/ui/monocle/FramebufferRegression.java
"$JAVA_HOME/bin/java" -cp "$out" com.sun.glass.ui.monocle.FramebufferRegression
