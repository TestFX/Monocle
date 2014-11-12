Monocle is the implementation of the Glass windowing component of JavaFX for embedded systems. It
is part of the Java Platform since version 8u20, but not included in builds for desktop platforms
(Windows, Linux, Mac).

This repository provides pre-packaged builds of Monocle taken from the OpenJFX project. The builds
include components to run in headless environments. They do not include native libraries for
low-level access.

## Build (under Windows)

Clone the repository and checkout the branch.

```
C:\> git clone https://github.com/TestFX/Monocle
C:\> cd Monocle
C:\> git checkout runtime-8u20
```

Choose the JDK version and build the jars.

```
C:\> set JAVA_HOME=C:\Program Files\Java\jdk1.8.0_20
C:\> gradlew clean jar
C:\> dir build\libs
```

## Update Instructions

To update the build to newer versions of Monocle just copy source code files from
[src/main/java/com/sun/glass/ui/monocle] into the directory `src\main\java` and resource files
from [src/main/resources/com/sun/glass/ui/monocle] into the directory `src\main\resources`. Use
the links `bz2`, `zip` or `gz` to export the files as archive.

You can update to a certain version by changing `tip` in the URLs to a changeset hash. There is a
list of changeset hashes at [http://hg.openjdk.java.net/openjfx/8u-dev/rt/tags]().

Example changeset hashes:

- **8u20-b26:** `e56a8bbcba20` instead of `tip`.
- **8u25-b18:** `b2021af209c3` instead of `tip`.
- **8u40-b13:** `b90398073b6a` instead of `tip`.

[src/main/java/com/sun/glass/ui/monocle]: http://hg.openjdk.java.net/openjfx/8u-dev/rt/file/tip/modules/graphics/src/main/java/com/sun/glass/ui/monocle
[src/main/resources/com/sun/glass/ui/monocle]: http://hg.openjdk.java.net/openjfx/8u-dev/rt/file/tip/modules/graphics/src/main/resources/com/sun/glass/ui/monocle
