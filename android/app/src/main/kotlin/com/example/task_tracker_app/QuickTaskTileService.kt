package com.example.task_tracker_app

import android.content.Intent
import android.service.quicksettings.TileService
import android.service.quicksettings.Tile

class QuickTaskTileService : TileService() {

    override fun onStartListening() {
        super.onStartListening()
        updateTile()
    }

    override fun onClick() {
        super.onClick()
        
        // Create intent to launch the app with quick task creation
        val intent = Intent(this, MainActivity::class.java).apply {
            action = "CREATE_QUICK_TASK"
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
        }
        
        startActivityAndCollapse(intent)
    }

    private fun updateTile() {
        qsTile?.let { tile ->
            tile.state = Tile.STATE_ACTIVE
            tile.label = "Quick Task"
            tile.contentDescription = "Create a quick task"
            tile.updateTile()
        }
    }
}