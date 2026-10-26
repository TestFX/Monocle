#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
out="${1:-build/headless-smoke}"
test ! -e "$out"
mkdir -p "$out"
"${JAVA_HOME:?Set JAVA_HOME}/bin/javac" --release 21 -cp "${JAVAFX_CLASSPATH:?Set the explicit JavaFX base/graphics classpath}" \
  -d "$out" src/test/java/com/sun/glass/ui/monocle/FramebufferHeadlessSmoke.java
"$JAVA_HOME/bin/java" --enable-native-access=ALL-UNNAMED -Dglass.platform=Monocle \
  -Dmonocle.platform=Headless -Dheadless.geometry=64x64-32 -Dprism.order=sw -Djava.awt.headless=true \
  -cp "$out:${MONOCLE_JAR:?Set the exact Monocle artifact}:$JAVAFX_CLASSPATH" \
  com.sun.glass.ui.monocle.FramebufferHeadlessSmoke
