# Monocle

**Monocle** is the implementation of the Glass windowing component of JavaFX for embedded systems.
It is part of the Java Platform since version 8u20 (released in August 2014), but not included in
builds for desktop platforms (Windows, Linux, Mac).

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
[src/main/java/com/sun/glass/ui/monocle](10) into the directory `src\main\java` and resource files
from [src/main/resources/com/sun/glass/ui/monocle](11) into the directory `src\main\resources`. Use
the links `bz2`, `zip` or `gz` to export the files as archive.

You can update to a certain version by changing `tip` in the URLs to a changeset hash. There is a
list of changeset hashes at [http://hg.openjdk.java.net/openjfx/8u-dev/rt/tags](12).

Example changeset hashes:

- **8u20-b26:** `e56a8bbcba20` instead of `tip`.
- **8u25-b18:** `b2021af209c3` instead of `tip`.
- **8u31-b13:** `f1388961b89f` instead of `tip`.
- **8u40-b27:** `e00e97499831` instead of `tip`.
- **8u60-b06:** `5fc0ddb42776` instead of `tip`.

[10]: http://hg.openjdk.java.net/openjfx/8u-dev/rt/file/tip/modules/graphics/src/main/java/com/sun/glass/ui/monocle
[11]: http://hg.openjdk.java.net/openjfx/8u-dev/rt/file/tip/modules/graphics/src/main/resources/com/sun/glass/ui/monocle
[12]: http://hg.openjdk.java.net/openjfx/8u-dev/rt/tags

## License

OpenJDK and OpenJFX are licensed under the [GNU General Public License, version 2, with the
Classpath Exception](20).

[20]: http://openjdk.java.net/legal/gplv2+ce.html
