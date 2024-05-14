package com.tahamalas.internet_speed_test

class Logger {
    var enabled = false

    fun print(message: String) {
        if (enabled)
            println(message)
    }
}