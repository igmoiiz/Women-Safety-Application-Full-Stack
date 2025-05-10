package com.example.women_safety

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.IntentSender
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Bundle
import android.location.Location
import android.widget.Toast
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.google.android.gms.common.api.ResolvableApiException
import com.google.android.gms.location.*

class WhatsAppRedirectActivity : Activity() {
    private val LOCATION_PERMISSION_REQUEST_CODE = 1000
    private val LOCATION_SETTINGS_REQUEST_CODE = 2000
    private val PHONE_NUMBER = "923120580303" // Added country code (92 for Pakistan)

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        checkLocationSettings()
    }

    private fun checkLocationSettings() {
        val locationRequest = LocationRequest.create().apply {
            priority = LocationRequest.PRIORITY_HIGH_ACCURACY
            interval = 10000 // 10 seconds
            fastestInterval = 5000 // 5 seconds
        }

        val builder = LocationSettingsRequest.Builder()
            .addLocationRequest(locationRequest)
            .setAlwaysShow(true) // This forces the dialog to show every time

        val client = LocationServices.getSettingsClient(this)
        val task = client.checkLocationSettings(builder.build())

        task.addOnSuccessListener {
            // Location settings are satisfied, proceed with permission check
            checkLocationPermission()
        }

        task.addOnFailureListener { exception ->
            if (exception is ResolvableApiException) {
                try {
                    // Show dialog to enable location services
                    exception.startResolutionForResult(this, LOCATION_SETTINGS_REQUEST_CODE)
                } catch (sendEx: IntentSender.SendIntentException) {
                    Toast.makeText(
                        this,
                        "Error opening location settings",
                        Toast.LENGTH_SHORT
                    ).show()
                    finish()
                }
            } else {
                Toast.makeText(
                    this,
                    "Location settings are not available",
                    Toast.LENGTH_SHORT
                ).show()
                finish()
            }
        }
    }

    // Handle location settings result
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        when (requestCode) {
            LOCATION_SETTINGS_REQUEST_CODE -> {
                when (resultCode) {
                    Activity.RESULT_OK -> {
                        // Double check if location is really enabled
                        val locationManager = getSystemService(Context.LOCATION_SERVICE) as android.location.LocationManager
                        if (locationManager.isProviderEnabled(android.location.LocationManager.GPS_PROVIDER)) {
                            checkLocationPermission()
                        } else {
                            Toast.makeText(
                                this,
                                "Location services must be enabled to use this feature",
                                Toast.LENGTH_LONG
                            ).show()
                            finish()
                        }
                    }
                    Activity.RESULT_CANCELED -> {
                        Toast.makeText(
                            this,
                            "Location services must be enabled to use this feature",
                            Toast.LENGTH_LONG
                        ).show()
                        finish()
                    }
                }
            }
        }
    }

    private fun checkLocationPermission() {
        if (ContextCompat.checkSelfPermission(
                this,
                Manifest.permission.ACCESS_FINE_LOCATION
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            ActivityCompat.requestPermissions(
                this,
                arrayOf(
                    Manifest.permission.ACCESS_FINE_LOCATION,
                    Manifest.permission.ACCESS_COARSE_LOCATION
                ),
                LOCATION_PERMISSION_REQUEST_CODE
            )
        } else {
            sendCurrentLocation()
        }
    }

    private fun sendCurrentLocation() {
        val fusedLocationClient = LocationServices.getFusedLocationProviderClient(this)
        if (ActivityCompat.checkSelfPermission(
                this,
                Manifest.permission.ACCESS_FINE_LOCATION
            ) == PackageManager.PERMISSION_GRANTED
        ) {
            fusedLocationClient.lastLocation
                .addOnSuccessListener { location: Location? ->
                    if (location != null) {
                        val latitude = location.latitude.toString()
                        val longitude = location.longitude.toString()
                        val locationUrl = "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude"
                        
                        // Add emergency alert text to the WhatsApp message
                        val emergencyMessage = "EMERGENCY ALERT! I need help immediately! My current location is: $locationUrl"
                        val url = "https://api.whatsapp.com/send?phone=$PHONE_NUMBER&text=${Uri.encode(emergencyMessage)}"
                        
                        val intent = Intent(Intent.ACTION_VIEW).apply {
                            data = Uri.parse(url)
                            `package` = "com.whatsapp"
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
                        }

                        try {
                            startActivity(intent)
                        } catch (e: Exception) {
                            Toast.makeText(this, "WhatsApp not installed", Toast.LENGTH_SHORT).show()
                            try {
                                startActivity(
                                    Intent(
                                        Intent.ACTION_VIEW,
                                        Uri.parse("market://details?id=com.whatsapp")
                                    )
                                )
                            } catch (e: Exception) {
                                startActivity(
                                    Intent(
                                        Intent.ACTION_VIEW,
                                        Uri.parse("https://play.google.com/store/apps/details?id=com.whatsapp")
                                    )
                                )
                            }
                        }
                    } else {
                        Toast.makeText(this, "Location not available", Toast.LENGTH_SHORT).show()
                    }
                    finish()
                }
                .addOnFailureListener { e ->
                    Toast.makeText(this, "Error getting location: ${e.message}", Toast.LENGTH_SHORT).show()
                    finish()
                }
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        when (requestCode) {
            LOCATION_PERMISSION_REQUEST_CODE -> {
                if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    sendCurrentLocation()
                } else {
                    Toast.makeText(
                        this,
                        "Location permission is required for this feature",
                        Toast.LENGTH_LONG
                    ).show()
                    finish()
                }
            }
        }
    }
}