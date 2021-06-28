package com.example.flutter_platform_channels

import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.content.IntentFilter
import android.hardware.Sensor
import android.hardware.SensorManager
import android.os.BatteryManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val tempChannelName = "temperature_channel"
    private val pressureChannelName = "pressure_channel"
    private lateinit var sensorManager: SensorManager
    private lateinit var eventChannel: EventChannel
    private lateinit var sensorStreamHandler: SensorStreamHandler

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        sensorManager =
            context.getSystemService(Context.SENSOR_SERVICE) as SensorManager
        val binaryMessenger = flutterEngine.dartExecutor.binaryMessenger

        callBatteryLevelChannel(binaryMessenger)
        callSensorChannel(binaryMessenger)
        createEventChannelFor(tempChannelName, binaryMessenger, Sensor.TYPE_AMBIENT_TEMPERATURE)
        createEventChannelFor(pressureChannelName, binaryMessenger, Sensor.TYPE_PRESSURE)
    }

    private fun createEventChannelFor(
        channelName: String,
        binaryMessenger: BinaryMessenger,
        sensorType: Int
    ) {
        eventChannel = EventChannel(binaryMessenger, channelName)
        sensorStreamHandler = SensorStreamHandler(sensorManager, sensorType)
        eventChannel.setStreamHandler(sensorStreamHandler)
    }

    private fun callBatteryLevelChannel(binaryMessenger: BinaryMessenger) {
        MethodChannel(binaryMessenger, "battery_level_channel")
            .setMethodCallHandler { call, result ->
                if (call.method == "getBatteryLevel") {
                    var batteryLevel = getBatteryLevel()
                    if (batteryLevel != -1) {
                        result.success(batteryLevel)
                    } else {
                        result.error("UNAVAILABLE", "Battery level not available.", null)
                    }
                } else {
                    result.notImplemented()
                }
            }
    }

    private fun callSensorChannel(binaryMessenger: BinaryMessenger) {
        MethodChannel(binaryMessenger, "sensor_channel")
            .setMethodCallHandler { call, result ->
                if (call.method == "sensorMethod") {

                    val arr: ArrayList<String> = arrayListOf()

                    for (i in sensorManager.getSensorList(Sensor.TYPE_ALL)) {
                        arr.add(i.name)
                    }
                    result.success(arr)
                } else {
                    result.notImplemented()
                }
            }
    }

    private fun getBatteryLevel(): Int {
        val batteryLevel: Int

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
            batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
        } else {
            val intent = ContextWrapper(applicationContext).registerReceiver(
                null,
                IntentFilter(
                    Intent.ACTION_BATTERY_CHANGED
                )
            )
            batteryLevel = intent?.getIntExtra(BatteryManager.EXTRA_STATUS, -1) ?: -1
        }
        return batteryLevel
    }
}
