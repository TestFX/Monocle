package com.sun.glass.ui.monocle;

import java.nio.*;
import java.util.ArrayList;
import java.util.List;

/** Standalone regression: no toolkit, display, native library or test framework. */
public final class FramebufferRegression {
    private static final int WIDTH = 8, HEIGHT = 6;

    private static void require(boolean condition, String message) {
        if (!condition) throw new AssertionError(message);
    }

    private static void check(boolean bytes, int width, int height, int px, int py) {
        int[] image = new int[width * height];
        for (int y = 0; y < height; y++) for (int x = 0; x < width; x++) {
            image[y * width + x] = 0xff000000 | ((y * 37 + x * 11 + 15) & 255) << 16
                    | ((x * 19 + 28) & 255) << 8 | ((y * 23 + x + 43) & 255);
        }
        Buffer source;
        if (bytes) {
            ByteBuffer b = ByteBuffer.allocate((image.length + 8) * 4).order(ByteOrder.nativeOrder());
            for (int i = 0; i < image.length; i++) b.putInt(i * 4, image[i]);
            source = b.position(12).limit(b.capacity() - 8).mark();
        } else {
            IntBuffer b = IntBuffer.allocate(image.length + 8);
            b.put(image);
            source = b.position(3).limit(b.capacity() - 2).mark();
        }
        int position = source.position(), limit = source.limit();
        ByteBuffer target = ByteBuffer.allocate(WIDTH * HEIGHT * 4).order(ByteOrder.nativeOrder());
        Framebuffer framebuffer = new Framebuffer(target, WIDTH, HEIGHT, 32, false);
        for (int frame = 0; frame < 2; frame++) {
            framebuffer.composePixels(source, px, py, width, height, 1f);
            require(source.position() == position && source.limit() == limit, "Caller cursor/limit changed");
            source.reset();
            require(source.position() == position, "Caller mark changed");
            for (int y = 0; y < HEIGHT; y++) for (int x = 0; x < WIDTH; x++) {
                int sx = x - px, sy = y - py;
                int expected = sx >= 0 && sx < width && sy >= 0 && sy < height ? image[sy * width + sx] : 0;
                require(target.getInt((y * WIDTH + x) * 4) == expected, "Wrong clipped pixel at " + x + "," + y + " frame " + frame);
            }
            // The real producer rewinds then overwrites a reused upload buffer.
            source.rewind();
            if (source instanceof IntBuffer b) b.put(image);
            else for (int pixel : image) ((ByteBuffer) source).putInt(pixel);
            source.position(position).mark();
        }
    }

    public static void main(String[] args) {
        List<String> failures = new ArrayList<>();
        int cases = 0;
        for (boolean bytes : new boolean[]{false, true})
            for (int width : new int[]{3, 8, 11}) for (int height : new int[]{4, 8})
                for (int x : new int[]{-2, 0, 2, 5}) for (int y : new int[]{-2, 0, 1, 4}) {
                    cases++;
                    try { check(bytes, width, height, x, y); }
                    catch (Throwable error) { failures.add((bytes ? "byte" : "int") + " " + width + "x" + height
                            + " at " + x + "," + y + ": " + error); }
                }
        failures.stream().limit(12).forEach(System.err::println);
        System.out.println("Framebuffer regression: " + cases + " cases, " + failures.size() + " failed; two frames per case");
        if (!failures.isEmpty()) throw new AssertionError("Framebuffer ownership/clipping regressions");
    }
}
