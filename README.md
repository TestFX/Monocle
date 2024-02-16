# OpenJFX Monocle

### NOTE
This is not the official OpenJFX Monocle repository. This repository is used to build
Monocle for use with TestFX. The official OpenJFX Monocle repository is located at
https://github.com/openjdk/jfx.

## Summary

**Monocle** is the implementation of the Glass windowing component of JavaFX for embedded systems
[\[1\]][1]. It is part of the Java Platform since version 8u20 (released in August 2014), but not
included in builds for desktop platforms (Windows, Linux, Mac) [\[2\]][2].

This repository provides pre-packaged builds of Monocle taken from the OpenJFX project. The builds
include components to run in headless environments. They do not include native libraries for
low-level access.

[1]: https://wiki.openjdk.java.net/display/OpenJFX/Monocle
[2]: http://mail.openjdk.java.net/pipermail/openjfx-dev/2014-November/016111.html

## Gradle

```gradle
testCompile 'org.testfx:openjfx-monocle:21.0.2' // For OpenJFX 21
testCompile 'org.testfx:openjfx-monocle:17.0.10' // For OpenJFX 17
testCompile 'org.testfx:openjfx-monocle:11.0.2' // For OpenJFX 11
testCompile 'org.testfx:openjfx-monocle:jdk-8.0.372' // For Java 8
```

## Maven

```xml
<dependency>
    <groupId>org.testfx</groupId>
    <artifactId>openjfx-monocle</artifactId>
    <version>21.0.2</version> <!-- 17.0.10 For OpenJFX 17, 11.0.2 For OpenJFX 11, jdk-8.0.372 for Java 8 -->
    <scope>test</scope>
</dependency>
```

## Build (under Windows)

There are branches for each of the LTS releases of OpenJFX. Currently, we are 
supporting four branches, until the support for each LTS release ends.

- **jdk-21:** OpenJFX 21
- **jdk-17:** OpenJFX 17
- **jdk-11:** OpenJFX 11
- **jdk-8:** OpenJFX 8u-dev

To build Monocle for a specific JDK version, clone the repository and checkout the tag.

```
C:\> git clone https://github.com/TestFX/Monocle
C:\> cd Monocle
C:\> git checkout jdk-21
```

Choose the JDK version and build the jars.

```
C:\> set JAVA_HOME=C:\Program Files\Java\jdk1.8.0_20
C:\> gradlew clean jar
C:\> dir build\libs
```

## Updating Monocle

To update the build to newer versions of Monocle just copy source code files from
[src/main/java/com/sun/glass/ui/monocle][10] into the directory `src/main/java` and resource files
from [src/main/resources/com/sun/glass/ui/monocle][11] into the directory `src/main/resources`. Use
the links `bz2`, `zip` or `gz` to export the files as archive.

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

## Issuing a Release

After you have either manually or automatically updated to the latest Monocle version
you can issue a release by doing the following:

### Upgraded Monocle Version is First Build (YY) for New Major Java Version (XX)

* Add the gradle dependency info to `README.md` under `Gradle` header:

```gradle
testCompile "org.testfx:openjfx-monocle:[openjdk.version]" // For OpenJFX XX
testCompile 'org.testfx:openjfx-monocle:21.0.2' // For OpenJFX 21
testCompile 'org.testfx:openjfx-monocle:17.0.10' // For OpenJFX 17
testCompile 'org.testfx:openjfx-monocle:11.0.2' // For OpenJFX 11
testCompile 'org.testfx:openjfx-monocle:jdk-8.0.372' // For Java 8
```

* Change the Maven dependency info in `README.md` under the `Maven` header:

```pom
<dependency>
    <groupId>org.testfx</groupId>
    <artifactId>openjfx-monocle</artifactId>
    <version>[openjdk.version]</version> <!-- 17.0.10 For OpenJFX 17, 11.0.2 For OpenJFX 11, jdk-8.0.372 for Java 8 -->
    <scope>test</scope>
</dependency>
```

* Bump the project version in `gradle.properties` to the new version:

```
group = org.testfx
version = [openjdk.version]
```


### Make the Release

* Commit the above changes with the commit message `(release) Monocle [openjdk.version].` to upstream
(either by creating a PR or pushing the commit directly).

* Tag the new commit (note the `v` prefix character so that the branch name does not conflict
with the tag name):

`git tag -a v[openjdk.version]`

* Push the tag to upstream:

`git push upstream v[openjdk.version]`

## License

OpenJDK and OpenJFX are licensed under the [GNU General Public License, version 2, with the
Classpath Exception][20].

[20]: http://openjdk.java.net/legal/gplv2+ce.html
