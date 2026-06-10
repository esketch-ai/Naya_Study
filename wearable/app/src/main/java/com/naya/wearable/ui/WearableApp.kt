package com.naya.wearable.ui

import android.Manifest
import android.bluetooth.BluetoothAdapter
import android.content.Context
import android.content.pm.PackageManager
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.core.content.ContextCompat
import com.naya.wearable.ble.BleGattService
import com.naya.wearable.still.StillMotionDetectionEngine

class WearableApp {
    private val context: Context by lazy { LocalContext.current }
    
    private var bleManager: BluetoothLeScanner? = null
    private var connectedDevice: BluetoothDevice? = null
    
    @Composable
    fun Content() {
        var isConnected by remember { mutableStateOf(false) }
        var heartRate by remember { mutableStateOf<Int?>(null) }
        
        // Request permissions
        val permissionLauncher = rememberActivityResultContract<ActivityResultContracts.RequestMultiplePermissions>()
            .launchScoped { permissions ->
                permissions.forEach { (permission, granted) ->
                    if (granted && !isConnected) {
                        connectToDevice()
                    }
                }
            }
        
        Column(
            modifier = Modifier.fillMaxSize(),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            Text("Naya Wearable", style = MaterialTheme.typography.headlineMedium)
            
            if (isConnected) {
                Card(modifier = Modifier.padding(16.dp)) {
                    Column(modifier = Modifier.padding(16.dp)) {
                        Text("Connected ✓")
                        
                        heartRate?.let { hr ->
                            Text("Heart Rate: $hr bpm", style = MaterialTheme.typography.bodyLarge)
                            
                            // STILL motion detection
                            val stillEngine = StillMotionDetectionEngine()
                            // Check motion here when data arrives
                        }
                    }
                }
            } else {
                Button(onClick = { /* Connect */ }) {
                    Text("Connect Device")
                }
            }
        }
    }
}
