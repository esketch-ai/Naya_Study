package com.naya.wearable

import android.Manifest
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothManager
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.naya.wearable.ble.BleGattService
import com.naya.wearable.sensors.AccelerometerEngine
import com.naya.wearable.sensors.PpgSensorService

class WearableMainActivity : AppCompatActivity() {
    
    private lateinit var accelerometerEngine: AccelerometerEngine
    private lateinit var ppgSensorService: PpgSensorService
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Initialize sensors
        accelerometerEngine = AccelerometerEngine(this)
        ppgSensorService = PpgSensorService(this)
        
        // Set up STILL detection listener
        accelerometerEngine.setOnStillDetectedListener { minutes ->
            println("⏸️ Device has been STILL for ${minutes} minutes")
            // Trigger PPG sampling (handled by PpgSensorService)
        }
        
        // Request necessary permissions
        requestPermissions()
    }
    
    private fun requestPermissions() {
        val requiredPermissions = mutableListOf<String>()
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            if (ContextCompat.checkSelfPermission(
                    this, Manifest.permission.BLUETOOTH_CONNECT
                ) != PackageManager.PERMISSION_GRANTED
            ) {
                requiredPermissions.add(Manifest.permission.BLUETOOTH_CONNECT)
            }
            
            if (ContextCompat.checkSelfPermission(
                    this, Manifest.permission.BLUETOOTH_SCAN
                ) != PackageManager.PERMISSION_GRANTED
            ) {
                requiredPermissions.add(Manifest.permission.BLUETOOTH_SCAN)
            }
        } else {
            if (ContextCompat.checkSelfPermission(
                    this, Manifest.permission.BLUETOOTH
                ) != PackageManager.PERMISSION_GRANTED
            ) {
                requiredPermissions.add(Manifest.permission.BLUETOOTH)
            }
            
            if (ContextCompat.checkSelfPermission(
                    this, Manifest.permission.BLUETOOTH_ADMIN
                ) != PackageManager.PERMISSION_GRANTED
            ) {
                requiredPermissions.add(Manifest.permission.BLUETOOTH_ADMIN)
            }
        }
        
        if (requiredPermissions.isNotEmpty()) {
            ActivityCompat.requestPermissions(
                this,
                requiredPermissions.toTypedArray(),
                BLUETOOTH_PERMISSION_REQUEST_CODE
            )
        }
    }
    
    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        
        if (requestCode == BLUETOOTH_PERMISSION_REQUEST_CODE) {
            val allGranted = grantResults.all { it != PackageManager.PERMISSION_GRANTED }
            
            if (!allGranted) {
                println("❌ Bluetooth permissions not granted")
            } else {
                println("✅ Bluetooth permissions granted")
                
                // Initialize BLE connection after permissions granted
                initializeBluetooth()
            }
        }
    }
    
    private fun initializeBluetooth() {
        val bluetoothManager = getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
        val bluetoothAdapter = bluetoothManager.adapter
        
        if (bluetoothAdapter == null) {
            println("⚠️ No Bluetooth adapter found")
            return
        }
        
        if (!bluetoothAdapter.isEnabled) {
            // Request user to enable Bluetooth
            val enableIntent = Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE)
            startActivity(enableIntent)
        } else {
            println("✅ Bluetooth is enabled")
            
            // Start scanning for wearable device
            startDeviceDiscovery(bluetoothAdapter)
        }
    }
    
    private fun startDeviceDiscovery(bluetoothAdapter: BluetoothAdapter) {
        // Implementation depends on your BLE library choice
        // This is a placeholder - you'd use something like:
        // - android.bluetooth.le.ScanCallback for native implementation
        // - Or a third-party library like BleManager
        
        println("🔍 Starting device discovery...")
    }
    
    companion object {
        private const val BLUETOOTH_PERMISSION_REQUEST_CODE = 1001
    }
}
