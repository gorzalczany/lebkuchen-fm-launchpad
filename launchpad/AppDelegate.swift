import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.variableLength)

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSApplication.shared.hide(nil)
        checkPermission()
        constructMenu()
        _ = KeyboardEventHandler.shared

        statusItem.button?.title = "FM"

        NotificationsHelper.askForPermission()
        NotificationsHelper.present(message: "Gotowe do działania")
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func checkPermission() {
        // this following lines will add Unshaky.app to privacy->accessibility panel, unchecked
        let checkOptPrompt = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString
        let accessEnabled = AXIsProcessTrustedWithOptions([checkOptPrompt: false] as CFDictionary?)

        if (!accessEnabled) {
            let alert = NSAlert()
            alert.messageText = "Accessibility Help"
            alert.informativeText = "Włącz launchpad w ustawieniach prywatności i ponownie uruchom aplikację."
            alert.runModal()
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
            NSApplication.shared.terminate(self)
        }
    }

    func constructMenu() {
        let importExport = NSMenuItem(title:  "Import/Export", action: nil, keyEquivalent: "")
        let importExportSubmenu = NSMenu()
        let importItem = NSMenuItem(title:  "Import", action: #selector(importSettings), keyEquivalent: "")
        let exportItem = NSMenuItem(title:  "Export", action: #selector(exportSettings), keyEquivalent: "")
        importExportSubmenu.addItem(importItem)
        importExportSubmenu.addItem(exportItem)
        importExport.submenu = importExportSubmenu

        let keyboardKey = NSMenuItem(title: "Keyboard", action: nil, keyEquivalent: "")
        let keyboardSubMenu = NSMenu()
        keyboardKey.submenu = keyboardSubMenu
        for i in 1...60 {
            keyboardSubMenu.addItem(withTitle: "\(i)", action: #selector(keyboardSelected(_:)), keyEquivalent: "")
        }

        let quit = NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "")
        let menu = NSMenu()
        menu.minimumWidth = 150
        menu.addItem(keyboardKey)
        menu.addItem(importExport)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(quit)

        statusItem.menu = menu
    }

    @objc func keyboardSelected(_ sender: NSMenuItem) {
        print(sender.state)
        let keyboardsString = UserDefaults.standard.string(forKey: "Keyboards") ?? ""
        var keyboards: [String] = keyboardsString.components(separatedBy: ";")

        switch sender.state {
        case .on:
            sender.state = .off
            keyboards = keyboards.filter {$0 != sender.title}
            let toSafe = keyboards.joined(separator: ";")
            UserDefaults.standard.set(toSafe, forKey: "Keyboards")
        default:
            sender.state = .on
            keyboards.append(sender.title)
            let toSafe = keyboards.joined(separator: ";")
            print(toSafe)
            UserDefaults.standard.set(toSafe, forKey: "Keyboards")
        }
    }


    @objc func importSettings() {
        let dialog = NSOpenPanel();

        dialog.title                   = "Choose a .json file"
        dialog.showsResizeIndicator    = false
        dialog.showsHiddenFiles        = false
        dialog.canChooseDirectories    = false
        dialog.canCreateDirectories    = false
        dialog.allowsMultipleSelection = false
        dialog.allowedFileTypes        = ["json"]

        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file

            if (result != nil) {
                let path = result!.path
                guard let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe),
                    let config = try? JSONDecoder().decode(LebkuchenLaunchpadConfig.self, from: data)
                    else { return }
                LebkuchenLaunchpadConfig.shared = config

            }
        } else {
            // User clicked on "Cancel"
            return
        }
    }

    @objc func exportSettings() {
        let dialog = NSOpenPanel();

        dialog.title                   = "Choose a .json file"
        dialog.showsResizeIndicator    = false
        dialog.showsHiddenFiles        = false
        dialog.canChooseDirectories    = true
        dialog.canChooseFiles = false
        dialog.representedFilename     = "launchpad_configuration"
        dialog.canCreateDirectories    = false
        dialog.allowsMultipleSelection = false
        dialog.allowedFileTypes        = ["json"]

        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            var result = dialog.url // Pathname of the file

            if (result != nil) {
                result?.appendPathComponent("launchpad_config", isDirectory: false)
                result?.appendPathExtension("json")
                let path = result!.path
                print(path)

                let configuration = LebkuchenLaunchpadConfig.shared
                let encoder = JSONEncoder()
                let data = try? encoder.encode(configuration!)
                FileManager.default.createFile(atPath: path, contents: data, attributes: [:])
            }
        } else {
            // User clicked on "Cancel"
            return
        }
    }
}
