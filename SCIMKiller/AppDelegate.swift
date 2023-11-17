//
//  AppDelegate.swift
//  SCIMKiller
//
//  Created by Xiao Xiao on 2023/04/03.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var statusBarItem: NSStatusItem!
    var eventMonitor: Any?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        createMenuBarItem()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    func createMenuBarItem() {
        let statusBar = NSStatusBar.system
        statusBarItem = statusBar.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusBarItem.button {
            button.image = NSImage(systemSymbolName: "pill.circle.fill", accessibilityDescription: "Kill SCIM")
            button.action = #selector(killSCIM)
            button.target = self
        }

        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .rightMouseDown) {  [weak self]  event in
            if event.window == self?.statusBarItem.button?.window {
                let menu = NSMenu()
                let menuItem = NSMenuItem(title: "Quit", action: #selector(self?.quitClicked), keyEquivalent: "")
                menu.addItem(menuItem)
                self?.statusBarItem.menu = menu
                self?.statusBarItem.button?.performClick(nil)
                self?.statusBarItem.menu = nil
            }
            return event
        }
    }

    @objc func killSCIM() {
        let processesToKill = [
            "SCIM",
            "SCIM_Extension",
            "TCIM",
            "TCIM_Extension"
        ]
        processesToKill.forEach { processName in
            let task = Process()
            task.launchPath = "/bin/sh"
            task.arguments = ["-c", "/usr/bin/pkill -9 \(processName)"]
            try? task.run()
        }
    }

    @objc func quitClicked() {
        exit(0)
    }
}

