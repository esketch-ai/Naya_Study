package com.naya.wearable.ble

import android.bluetooth.BluetoothGatt
import android.bluetooth.BluetoothGattCallback
import android.bluetooth.BluetoothGattCharacteristic
import android.bluetooth.BluetoothProfile
import android.util.Log
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.callbackFlow
import kotlinx.coroutines.tasks.await

/**
 * BLE GATT Service for Naya Wearable Device
 * 
 * Service UUID: 9E150000-B5A2-43E3-8F43-7D15A206079E
 */
object BleGattService {
    
    private const val TAG = "NayaBLE"
    
    // GATT Service UUID
    private val SERVICE_UUID = "9E150000-B5A2-43E3-8F43-7D15A206079E".uuid
    
    // Characteristic UUIDs
    private val HEART_RATE_MEASUREMENT_UUID = "9E150001-B5A2-43E3-8F43-7D15A206079E".uuid
    private val HRV_RMSSD_VALUE_UUID = "9E150002-B5A2-43E3-8F43-7D15A206079E".uuid
    private val DEVICE_ACTIVITY_STATE_UUID = "9E150003-B5A2-43E3-8F43-7D15A206079E".uuid
    
    /**
     * Heart Rate Measurement (UINT8, Notify)
     */
    private val HEART_RATE_MEASUREMENT = BluetoothGattCharacteristic(
        HEART_RATE_MEASUREMENT_UUID,
        BluetoothGattCharacteristic.PROPERTY_NOTIFY or BluetoothGattCharacteristic.PERMISSION_READ,
        BluetoothGattCharacteristic.FORMAT_UINT8
    )
    
    /**
     * HRV RMSSD Value (FLOAT32, Notify)
     */
    private val HRV_RMSSD_VALUE = BluetoothGattCharacteristic(
        HRV_RMSSD_VALUE_UUID,
        BluetoothGattCharacteristic.PROPERTY_NOTIFY or BluetoothGattCharacteristic.PERMISSION_READ,
        BluetoothGattCharacteristic.FORMAT_FLOAT_32
    )
    
    /**
     * Device Activity State (UINT8, Notify)
     * 0: STILL, 1: WALKING, 2: IN_VEHICLE, 3: SLEEP
     */
    private val DEVICE_ACTIVITY_STATE = BluetoothGattCharacteristic(
        DEVICE_ACTIVITY_STATE_UUID,
        BluetoothGattCharacteristic.PROPERTY_NOTIFY or BluetoothGattCharacteristic.PERMISSION_READ,
        BluetoothGattCharacteristic.FORMAT_UINT8
    )
    
    /**
     * Flow of Heart Rate measurements from wearable device
     */
    fun observeHeartRate(gatt: BluetoothGatt): Flow<Int> {
        return callbackFlow {
            val callback = object : BluetoothGattCallback() {
                override fun onCharacteristicChanged(gatt: BluetoothGatt?, characteristic: BluetoothGattCharacteristic?) {
                    if (characteristic?.uuid == HEART_RATE_MEASUREMENT_UUID) {
                        try {
                            val data = characteristic.value ?: return
                            val heartRate = data[0].toInt() and 0xFF
                            trySend(heartRate)
                            Log.d(TAG, "❤️ Heart Rate: $heartRate BPM")
                        } catch (e: Exception) {
                            Log.e(TAG, "Error parsing heart rate", e)
                        }
                    }
                }
            }
            
            gatt.setCharacteristicNotification(HEART_RATE_MEASUREMENT, true)
            gatt.services?.forEach { service ->
                if (service.uuid == SERVICE_UUID) {
                    service.getCharacteristic(HEART_RATE_MEASUREMENT_UUID)?.let { char ->
                        char.descriptor?.let { desc ->
                            desc.uuid.toString() == "00002902-0000-1000-8000-00805f9b34fb" &&
                                gatt.setCharacteristicNotification(desc, true)
                        }
                    }
                }
            }
            
            awaitClose { gatt.disconnect() }
        }
    }
    
    /**
     * Flow of HRV RMSSD values from wearable device
     */
    fun observeHrvRmssd(gatt: BluetoothGatt): Flow<Double> {
        return callbackFlow {
            val callback = object : BluetoothGattCallback() {
                override fun onCharacteristicChanged(gatt: BluetoothGatt?, characteristic: BluetoothGattCharacteristic?) {
                    if (characteristic?.uuid == HRV_RMSSD_VALUE_UUID) {
                        try {
                            val data = characteristic.value ?: return
                            // Parse FLOAT32 from byte array
                            val bytes = ByteArray(4)
                            System.arraycopy(data, 0, bytes, 0, 4)
                            val hrv = java.lang.Float.intBitsToFloat(bytes.toInt())
                            trySend(hrv.toDouble())
                            Log.d(TAG, "📊 HRV RMSSD: ${String.format("%.2f", hrv)}")
                        } catch (e: Exception) {
                            Log.e(TAG, "Error parsing HRV", e)
                        }
                    }
                }
            }
            
            gatt.setCharacteristicNotification(HRV_RMSSD_VALUE, true)
            gatt.services?.forEach { service ->
                if (service.uuid == SERVICE_UUID) {
                    service.getCharacteristic(HRV_RMSSD_VALUE_UUID)?.let { char ->
                        char.descriptor?.let { desc ->
                            desc.uuid.toString() == "00002902-0000-1000-8000-00805f9b34fb" &&
                                gatt.setCharacteristicNotification(desc, true)
                        }
                    }
                }
            }
            
            awaitClose { gatt.disconnect() }
        }
    }
    
    /**
     * Flow of Device Activity State from wearable device
     */
    fun observeActivityState(gatt: BluetoothGatt): Flow<DeviceActivityState> {
        return callbackFlow {
            val callback = object : BluetoothGattCallback() {
                override fun onCharacteristicChanged(gatt: BluetoothGatt?, characteristic: BluetoothGattCharacteristic?) {
                    if (characteristic?.uuid == DEVICE_ACTIVITY_STATE_UUID) {
                        try {
                            val data = characteristic.value ?: return
                            val state = data[0].toInt() and 0xFF
                            val activityState = when (state) {
                                0 -> DeviceActivityState.STILL
                                1 -> DeviceActivityState.WALKING
                                2 -> DeviceActivityState.IN_VEHICLE
                                3 -> DeviceActivityState.SLEEP
                                else -> DeviceActivityState.UNKNOWN
                            }
                            trySend(activityState)
                            Log.d(TAG, "🏃 Activity State: ${activityState.name}")
                        } catch (e: Exception) {
                            Log.e(TAG, "Error parsing activity state", e)
                        }
                    }
                }
            }
            
            gatt.setCharacteristicNotification(DEVICE_ACTIVITY_STATE, true)
            gatt.services?.forEach { service ->
                if (service.uuid == SERVICE_UUID) {
                    service.getCharacteristic(DEVICE_ACTIVITY_STATE_UUID)?.let { char ->
                        char.descriptor?.let { desc ->
                            desc.uuid.toString() == "00002902-0000-1000-8000-00805f9b34fb" &&
                                gatt.setCharacteristicNotification(desc, true)
                        }
                    }
                }
            }
            
            awaitClose { gatt.disconnect() }
        }
    }
    
    enum class DeviceActivityState {
        STILL, WALKING, IN_VEHICLE, SLEEP, UNKNOWN
    }
}
