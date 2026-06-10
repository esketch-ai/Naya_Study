package com.naya.systemalertwindow;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.pm.PackageManager;
import android.graphics.PixelFormat;
import android.os.Build;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.WindowManager;
import android.widget.FrameLayout;

public class SystemAlertWindowManager {
    
    private static final int SYSTEM_ALERT_WINDOW_PERMISSION = 1;
    private WindowManager windowManager;
    private View overlayView;
    
    public void initialize(Activity activity) {
        // Request SYSTEM_ALERT_WINDOW permission
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (activity.checkSelfPermission(Manifest.permission.SYSTEM_ALERT_WINDOW) 
                    != PackageManager.PERMISSION_GRANTED) {
                activity.requestPermissions(
                    new String[]{Manifest.permission.SYSTEM_ALERT_WINDOW},
                    SYSTEM_ALERT_WINDOW_PERMISSION
                );
            }
        }
    }
    
    public void createOverlay(Activity activity, View contentView) {
        windowManager = (WindowManager) activity.getSystemService(Context.WINDOW_SERVICE);
        
        // Create overlay view with System Alert Window type
        WindowManager.LayoutParams params = new WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.TYPE_SYSTEM_ALERT,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE |
            WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN |
            WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON |
            WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED,
            PixelFormat.TRANSLUCENT
        );
        
        params.gravity = Gravity.CENTER;
        overlayView = contentView;
        windowManager.addView(overlayView, params);
    }
    
    public void removeOverlay() {
        if (overlayView != null && windowManager != null) {
            windowManager.removeViewImmediate(overlayView);
            overlayView = null;
        }
    }
}
