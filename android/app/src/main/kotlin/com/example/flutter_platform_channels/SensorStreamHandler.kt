package com.example.flutter_platform_channels

import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import io.flutter.plugin.common.EventChannel

class SensorStreamHandler(
    var sensorManager: SensorManager,
    var sensorType: Int,
    var interval: Int = SensorManager.SENSOR_DELAY_NORMAL
) : EventChannel.StreamHandler, SensorEventListener {
    private val sensor = sensorManager.getDefaultSensor(sensorType)
    private var eventSink: EventChannel.EventSink? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        if (sensor != null) {
            eventSink = events
            sensorManager.registerListener(this, sensor, interval)
        }
    }

    override fun onCancel(arguments: Any?) {
        sensorManager.unregisterListener(this)
        eventSink = null
    }

    override fun onSensorChanged(event: SensorEvent?) {
        val sensorValue = event!!.values[0]
        eventSink?.success(sensorValue)
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
    }
}
