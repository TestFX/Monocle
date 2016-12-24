# OpenJFX Monocle

**Monocle** is the implementation of the Glass windowing component of JavaFX for embedded systems
[\[1\]][1]. It is part of the Java Platform since version 8u20 (released in August 2014), but not
included in builds for desktop platforms (Windows, Linux, Mac) [\[2\]][2].

This repository provides pre-packaged builds of Monocle taken from the OpenJFX project. The builds
include components to run in headless environments. They do not include native libraries for
low-level access.

[1]: https://wiki.openjdk.java.net/display/OpenJFX/Monocle
[2]: http://mail.openjdk.java.net/pipermail/openjfx-dev/2014-November/016111.html

## Build (under Windows)

Clone the repository and checkout the tag.

```
C:\> git clone https://github.com/TestFX/Monocle
C:\> cd Monocle
C:\> git checkout 8u20-b26
```

Choose the JDK version and build the jars.

```
C:\> set JAVA_HOME=C:\Program Files\Java\jdk1.8.0_20
C:\> gradlew clean jar
C:\> dir build\libs
```

## Manual Update

To update the build to newer versions of Monocle just copy source code files from
[src/main/java/com/sun/glass/ui/monocle][10] into the directory `src/main/java` and resource files
from [src/main/resources/com/sun/glass/ui/monocle][11] into the directory `src/main/resources`. Use
the links `bz2`, `zip` or `gz` to export the files as archive.

You can update to a certain version by changing `tip` in the URLs to a changeset hash. There is a
list of changeset hashes at [openjfx/8u-dev/rt/tags][12].

Example changeset hashes:

- **8u20-b26:** `e56a8bbcba20` instead of `tip`.
- **8u40-b27:** `e00e97499831` instead of `tip`.
- **8u60-b27:** `cff3afdde691` instead of `tip`.

[10]: http://hg.openjdk.java.net/openjfx/8u-dev/rt/file/tip/modules/graphics/src/main/java/com/sun/glass/ui/monocle
[11]: http://hg.openjdk.java.net/openjfx/8u-dev/rt/file/tip/modules/graphics/src/main/resources/com/sun/glass/ui/monocle
[12]: http://hg.openjdk.java.net/openjfx/8u-dev/rt/tags

## Automatic Update (beta)

The `sync.sh` Bash script attempts to automate the process of updating to a newer version
of Monocle from the OpenJFX repository. The script will look for the highest build number
(such as b00, b01, etc.) for each version (such as 8u45, 8u60, etc.) and if there is no
corresponding tag in this repository for that version/build number combination it will
offer to open a pull-request with the changeset from the upstream OpenJFX repository.
The PR is opened using the [hub][13] tool (which is automatically downloaded if you
do not have it installed). This script should work on any flavor of Linux (including
the Windows Subsystem for Linux) and macOS. Improvements to it are very welcome!

[13]: https://github.com/github/hub

## License

OpenJDK and OpenJFX are licensed under the [GNU General Public License, version 2, with the
Classpath Exception][20].

[20]: http://openjdk.java.net/legal/gplv2+ce.html
