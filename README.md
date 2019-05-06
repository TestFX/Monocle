# OpenJFX Monocle

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
testCompile "org.testfx:openjfx-monocle:jdk-12.0.1+2" // For Java 12
testCompile "org.testfx:openjfx-monocle:jdk-11+26" // For Java 11
testCompile "org.testfx:openjfx-monocle:jdk-9+181" // For Java 9
testCompile "org.testfx:openjfx-monocle:8u76-b04" // For Java 8
```

## Maven

```xml
<dependency>
    <groupId>org.testfx</groupId>
    <artifactId>openjfx-monocle</artifactId>
    <version>jdk-12.0.1+2</version> <!-- jdk-11+26 for Java 11, jdk-9+181 for Java 9, 8u76-b04 for Java 8 -->
    <scope>test</scope>
</dependency>
```

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

## Issuing a Release

After you have either manually or automatically updated to the latest Monocle version
you can issue a release by doing the following:

### Upgraded Monocle Version is First Build (YY) for New Major Java Version (XX)

* Add the gradle dependency info to `README.md` under `Gradle` header:

```gradle
testCompile "org.testfx:openjfx-monocle:jdk-XX+YY" // For Java XX
testCompile "org.testfx:openjfx-monocle:jdk-11+26" // For Java 11
testCompile "org.testfx:openjfx-monocle:jdk-9+181" // For Java 9
testCompile "org.testfx:openjfx-monocle:8u76-b04" // For Java 8
```

* Change the Maven dependency info in `README.md` under the `Maven` header:

```pom
<dependency>
    <groupId>org.testfx</groupId>
    <artifactId>openjfx-monocle</artifactId>
    <version>jdk-XX+YY</version> <!-- jdk-11+26 for Java 11, jdk-9+181 for Java 9, 8u76-b04 for Java 8 -->
    <scope>test</scope>
</dependency>
```

* Bump the project version in `gradle.properties` to the new version:

```
group = org.testfx
version = jdk-XX+YY
```


### Upgraded Monocle Version is New (Not First) Build (YY) for Existing Major Java Version (XX)

Assume XX is `12`, then:

* Change the gradle dependency info to `README.md` under `Gradle` header:

```gradle
testCompile "org.testfx:openjfx-monocle:jdk-12+YY" // For Java 12
testCompile "org.testfx:openjfx-monocle:jdk-9+181" // For Java 9
testCompile "org.testfx:openjfx-monocle:8u76-b04" // For Java 8
```

* Change the Maven dependency info in `README.md` under the `Maven` header:

```pom
<dependency>
    <groupId>org.testfx</groupId>
    <artifactId>openjfx-monocle</artifactId>
    <version>jdk-12+YY</version> <!-- jdk-9+181 for Java 9, 8u76-b04 for Java 8 -->
    <scope>test</scope>
</dependency>
```
* Bump the project version in `gradle.properties` to the new version:

```
group = org.testfx
version = jdk-12+YY
```

### Make the Release

* Commit the above changes with the commit message `(release) Monocle jdk-XX+YY.` to upstream
(either by creating a PR or pushing the commit directly).

* Tag the new commit (note the `v` prefix character so that the branch name does not conflict
with the tag name):

`git tag -a vXX+YY`

* Push the tag to upstream:

`git push upstream vXX+YY`

* Run gradle-bintray-plugin:

```powershell
gradlew bintray -PbintrayUsername=${BINTRAY_USERNAME} -PbintrayApiKey=${BINTRAY_API_KEY} -Dorg.gradle.java.home="%ProgramFiles%\Java\XX.YY"
```

## License

OpenJDK and OpenJFX are licensed under the [GNU General Public License, version 2, with the
Classpath Exception][20].

[20]: http://openjdk.java.net/legal/gplv2+ce.html
