//AppDelegate.swift
import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp?.windows.forEach {
            $0.acceptsMouseMovedEvents = true
            $0.isMovableByWindowBackground = true
            $0.makeKeyAndOrderFront(nil)
        }
    }
}
