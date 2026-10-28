package com.sun.glass.ui.monocle;

import java.util.concurrent.CompletableFuture;
import java.util.concurrent.TimeUnit;
import javafx.animation.KeyFrame;
import javafx.animation.Timeline;
import javafx.application.Platform;
import javafx.scene.Scene;
import javafx.scene.layout.Pane;
import javafx.scene.paint.Color;
import javafx.scene.shape.Rectangle;
import javafx.stage.Stage;
import javafx.stage.StageStyle;
import javafx.util.Duration;

/** Exercise real repeated, clipped native uploads; stderr is part of the check. */
public final class FramebufferHeadlessSmoke {
    public static void main(String[] args) throws Exception {
        CompletableFuture<Integer> result = new CompletableFuture<>();
        Platform.startup(() -> {
            Platform.setImplicitExit(false);
            Thread.currentThread().setUncaughtExceptionHandler((t, error) -> result.completeExceptionally(error));
            Stage stage = new Stage(StageStyle.UNDECORATED);
            Rectangle ink = new Rectangle(100, 100, Color.RED);
            stage.setScene(new Scene(new Pane(ink), 80, 80));
            stage.setX(0); stage.setY(0); stage.show();
            int[] frame = {0};
            Timeline timer = new Timeline(new KeyFrame(Duration.millis(40), event -> {
                int i = frame[0]++;
                if (i == 24) {
                    System.out.println("Framebuffer native smoke: 24 requested clipped frames; stage="
                            + stage.getWidth() + "x" + stage.getHeight());
                    stage.close(); result.complete(24);
                    return;
                }
                ink.setFill(i % 2 == 0 ? Color.BLUE : Color.RED);
                stage.setX(i % 3 == 0 ? 0 : i % 3 == 1 ? 19 : -9);
                stage.setY(i % 3 == 0 ? 0 : i % 3 == 1 ? 23 : -7);
            }));
            timer.setCycleCount(25); timer.play();
        });
        try {
            if (result.get(20, TimeUnit.SECONDS) != 24) throw new AssertionError("Incomplete native uploads");
        } finally { Platform.exit(); }
    }
}
