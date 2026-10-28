# Framebuffer composition ownership and clipping

`Framebuffer.composePixels` must preserve the caller's source buffer cursor,
limit, mark and byte order. The upload producer rewinds and overwrites the same
buffer on its next frame; a clipped compositor limit must not escape into that
next upload. Composition now uses its own duplicate view, starting at the image
origin, with the original byte order. This adds a small buffer-view object per
upload, without copying the pixel array. No allocation or throughput claim is made.

A source clipped to the destination width can still have a larger source stride.
The contiguous-copy path now requires matching row strides; otherwise rows are
copied separately. A negative vertical offset is included in the end offset of a
contiguous copy. These changes preserve the exact source pixel coordinates.

`FramebufferRegression` covers192 byte/int source, width/height and positive/
negative offset cases, with two frames per case. It verifies every destination
pixel, caller cursor/limit/mark and producer buffer reuse. The second upload also
exercises composition into a previously populated framebuffer. The unfixed
21.0.2 implementation fails192/192 cases. No toolkit/display/native library is
needed for this regression.

Run `./gradlew check` with JDK21. For the standalone regression use
`JAVA_HOME=/path/to/jdk21 sh tools/check-framebuffer.sh build/new-output`.
The output directory must be new. The standalone check also runs with JDK25.

Consumer: ephys4s, root Mote `ephys4s-provider-monocle-framebuffer`; triggering
qualification is `docs/verification/native-keyboard-2026-10-26` in that repository.
The baseline source is TestFX/Monocle jdk-21 revision
29a2343bbae34d1f80947f4160aee33c906d7c25, byte-identical to the Maven21.0.2 source.
This local candidate is unpublished. Canonical admission remains a separate gate.
