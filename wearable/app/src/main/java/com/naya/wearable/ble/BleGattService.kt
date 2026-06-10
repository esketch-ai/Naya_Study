package com.naya.wearable.ble

import android.bluetooth.*
import android.content.Context
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import kotlinx.coroutines.*
import java.util.UUID

class BleGattService {
    companion object {
        const val SERVICE_UUID = "9E150000-B5A2-43E3-8F43-7D15A206079E"
        
        const val HEART_RATE_MEASUREMENT = "9E150001-B5A2-43E3-8F43-7D15A206079E"
        const val HRV_RMSSD_VALUE = "9E150002-B5A2-43E3-8F43-7D15A206079E"
        const val DEVICE_ACTIVITY_STATE = "9E150003-B5A2-43E3-8F43-7D15A206079E"
        
        private const val MTU_SIZE = 20
        
        fun parseHeartRate(value: ByteArray): Int {
            return value[0].toInt() and 0xFF
        }
        
        fun parseHrmssd(value: ByteArray): Float {
            val bytes = value.copyOfRange(1, 5)
            return ByteBuffer.wrap(bytes).order(ByteBuffer.BIG_ENDIAN).float
        }
        
        fun parseActivityState(value: ByteArray): Int {
            return value[0].toInt() and 0xFF
        }
    }
}
