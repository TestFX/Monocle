# Monocle Source

It is often difficult to remember where to find the Monocle source code in 
order to build it. This document notes where to find the Monocle source code
for Java LTS versions.

In all cases, the code for Monocle is found in the following folder in the source archive:

`modules/javafx.graphics/src/main/java/com/sun/glass/ui/monocle`

## JFX 21
Since JFX 14 all JFX source code is now on [Github](#github)

URL: https://github.com/openjdk/jfx/tree/jfx21

## JFX 17

Since JFX 14 all JFX source code is now on [Github](#github)

URL: https://github.com/openjdk/jfx/tree/jfx17

## JFX 11

Version 11.0.2 was the last freely supported version of JFX 11. All other 
releases require an LTS support contract with Gluon.

Download 11.0.2 from [Gluon](#gluon): https://download2.gluonhq.com/openjfx/11.0.2/openjfx-11.0.2_linux-x64_bin-sdk.zip


## JFX 8
JavaFX 8 source code is bundled with any JDK 8 release. 

URL: https://adoptium.net/temurin/releases/?os=linux&arch=x64&package=jdk&version=8

## GitHub
1. Navigate to: https://github.com/openjdk/jfx
1. Select the branch for the version of JFX for which you are building Monocle
1. Click the `<> Code` button
1. Click the `Download ZIP` link

## Gluon
1. Navigate to: https://gluonhq.com/products/javafx/
1. Scroll down to `Downloads` section
1. Select the `Include older versions` checkbox
1. Choose the version of JFX for which you are building Monocle
1. Click the `Download` button

## Eclipse Temurin
1. Navigate to: https://adoptium.net/temurin/releases
1. Select the version of Java for which you are building Monocle
1. Click the archive link to download
