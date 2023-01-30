package io.openim.app.enterprisechat;

import android.content.Intent;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import io.flutter.embedding.android.FlutterFragmentActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterFragmentActivity {
    public static final String CHANNEL = "AliveHelp.io/commit";
    private MethodChannel channel;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        channel = new MethodChannel(flutterEngine.getDartExecutor(), CHANNEL);
    }

    private void backDesktop() {
        Intent i = new Intent(Intent.ACTION_MAIN);
        i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        i.addCategory(Intent.CATEGORY_HOME);
        startActivity(i);
    }

    @Override
    public void onBackPressed() {
        channel.invokeMethod("isHomeRoute",
                null, new MethodChannel.Result() {
                    @Override
                    public void success(@Nullable Object result) {
                        if (result instanceof Boolean && (Boolean) result) {
                            backDesktop();
                        } else {
                            MainActivity.super.onBackPressed();
                        }
                    }

                    @Override
                    public void error(@NonNull String errorCode, @Nullable String errorMessage, @Nullable Object errorDetails) {
                        MainActivity.super.onBackPressed();
                    }

                    @Override
                    public void notImplemented() {
                        MainActivity.super.onBackPressed();
                    }
                });
    }
}
