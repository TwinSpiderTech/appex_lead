package com.twinspider.appex_lead

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.ContentValues
import android.content.Context
import android.content.Intent
import android.database.sqlite.SQLiteDatabase
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.os.Build
import android.os.Bundle
import android.os.IBinder
import android.util.Log
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

// LocationTrackingService listens to GPS updates in the background and writes them to SQLite.
class LocationTrackingService : Service(), LocationListener {

    // Manager class for Android system location services
    private var locationManager: LocationManager? = null
    // Holds the ID of the active route currently being tracked
    private var activeRouteId: Long = -1
    // Log tag for terminal debugging
    private val TAG = "LocationTrackingService"
    // ID for the system notification channel
    private val CHANNEL_ID = "native_tracking_channel"
    // Notification ID to identify and update the active notification
    private val NOTIFICATION_ID = 999

    override fun onCreate() {
        super.onCreate() // Initialize parent Service
        Log.d(TAG, "Service Created") // Log lifecycle start
        // Retrieve the Android system Location service
        locationManager = getSystemService(Context.LOCATION_SERVICE) as LocationManager
        // Register the notification channel required for Android Oreo and above
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "Service Started") // Log command start
        // Retrieve the route_id passed from Dart, defaulting to -1 if absent
        val routeIdExtra = intent?.getLongExtra("route_id", -1) ?: -1
        // Assign the route ID or search the SQLite database if the service restarted
        activeRouteId = if (routeIdExtra != -1L) routeIdExtra else findActiveRouteIdFromDb()

        // Build a persistent notification instructing the user on how to stop it
        val notification = buildNotification(
            "Tracking Active", 
            "App is running in background. Open app to manually stop tracking."
        )
        // Bind the service state to the notification bar, preventing OS termination
        startForeground(NOTIFICATION_ID, notification)

        try {
            // Request location updates every 5000ms (5s) or 10 meters change
            locationManager?.requestLocationUpdates(LocationManager.GPS_PROVIDER, 5000L, 10f, this)
        } catch (e: SecurityException) {
            Log.e(TAG, "Location permission missing: ${e.message}") // Log permission issue
        }

        // START_STICKY tells Android to automatically restart the service if killed by RAM scheduler
        return START_STICKY
    }

    override fun onLocationChanged(location: Location) {
        Log.d(TAG, "Location Changed: Lat: ${location.latitude}, Lng: ${location.longitude}")
        // Persist the coordinates directly to the route_points database table
        saveLocationToDb(location)

        // Format dynamic text to display the current coordinates in the notification bar
        val coordText = String.format(Locale.US, "Tracking Active (Lat: %.4f, Lng: %.4f). Open app to stop.", location.latitude, location.longitude)
        // Access system notification service to update the layout
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        // Update the existing persistent notification with the new coordinates
        notificationManager.notify(NOTIFICATION_ID, buildNotification("Tracking Active", coordText))
    }

    private fun findActiveRouteIdFromDb(): Long {
        var routeId: Long = -1 // Default value if no active route exists
        try {
            // Get full absolute file path to the app's SQLite database
            val dbPath = getDatabasePath("route_tracking.db").absolutePath
            // Open the SQLite database in read-only mode
            val database = SQLiteDatabase.openDatabase(dbPath, null, SQLiteDatabase.OPEN_READONLY)
            // Query for the first active route record
            val cursor = database.rawQuery("SELECT id FROM routes WHERE status = 'active' LIMIT 1", null)
            if (cursor.moveToFirst()) {
                routeId = cursor.getLong(0) // Read the ID from the first column
            }
            cursor.close() // Close the dataset cursor to prevent memory leaks
            database.close() // Close the database connection
        } catch (e: Exception) {
            Log.e(TAG, "Error finding active route from DB: ${e.message}") // Log exception details
        }
        return routeId // Return the active route ID
    }

    private fun saveLocationToDb(location: Location) {
        if (activeRouteId == -1L) { // If route ID is still unassigned
            activeRouteId = findActiveRouteIdFromDb() // Fetch it from the database
            if (activeRouteId == -1L) {
                Log.e(TAG, "No active route ID found. Location not saved.") // Log and exit if none
                return
            }
        }
        try {
            // Get full path to the SQLite database
            val dbPath = getDatabasePath("route_tracking.db").absolutePath
            // Open the SQLite database in read-write mode
            val database = SQLiteDatabase.openDatabase(dbPath, null, SQLiteDatabase.OPEN_READWRITE)

            // Prepare key-value content values matching database columns
            val values = ContentValues().apply {
                put("route_id", activeRouteId)
                put("latitude", location.latitude)
                put("longitude", location.longitude)
                put("timestamp", SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS", Locale.US).format(Date()))
                put("speed", location.speed)
                put("accuracy", location.accuracy)
            }

            // Insert coordinates row into route_points table
            database.insert("route_points", null, values)
            database.close() // Close database connection to save changes and prevent leaks
            Log.d(TAG, "Successfully saved location to DB for Route #$activeRouteId")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to save location to DB: ${e.message}") // Log database insertion failure
        }
    }

    private fun buildNotification(title: String, content: String): Notification {
        // Retrieve native package manager launcher intent to open the app on click
        val intent = packageManager.getLaunchIntentForPackage(packageName)
        // Wrap the intent in a PendingIntent to authorize execution from the notification drawer
        val pendingIntent = PendingIntent.getActivity(this, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)

        // Instantiate builder using notification channels on Android Oreo+
        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, CHANNEL_ID)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
        }

        // Configure notification UI parameters
        return builder
            .setContentTitle(title) // Set main header text
            .setContentText(content) // Set body content text
            .setSmallIcon(android.R.drawable.ic_menu_mylocation) // Set small status bar icon
            .setContentIntent(pendingIntent) // Set redirect action on click
            .setOngoing(true) // Set ongoing to true, preventing users from swiping it away
            .build() // Build final Notification object
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) { // Channel is only required on API 26+
            // Set up a low importance channel to avoid intrusive sound/popup alerts on every GPS update
            val serviceChannel = NotificationChannel(CHANNEL_ID, "Native Route Tracking", NotificationManager.IMPORTANCE_LOW)
            val manager = getSystemService(NotificationManager::class.java) // Get system service manager
            manager?.createNotificationChannel(serviceChannel) // Register channel in OS settings
        }
    }

    override fun onDestroy() {
        super.onDestroy() // Destroy service resources
        Log.d(TAG, "Service Destroyed") // Log termination
        locationManager?.removeUpdates(this) // Unsubscribe from GPS updates to conserve battery
    }

    override fun onBind(intent: Intent?): IBinder? = null // Binding is not supported/required
    override fun onStatusChanged(provider: String?, status: Int, extras: Bundle?) {}
    override fun onProviderEnabled(provider: String) {}
    override fun onProviderDisabled(provider: String) {}
}
