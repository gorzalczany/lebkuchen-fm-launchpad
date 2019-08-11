import Foundation

extension KeyboardEventHandler {
    func setup() {
        let eventMask = (1 << CGEventType.keyDown.rawValue) | (1 << CGEventType.keyUp.rawValue) | (1 << CGEventType.flagsChanged.rawValue)
        guard let eventTap = CGEvent.tapCreate(tap: .cgSessionEventTap,
                                               place: .headInsertEventTap,
                                               options: .defaultTap,
                                               eventsOfInterest: CGEventMask(eventMask),
                                               callback: myCGEventCallback,
                                               userInfo: nil) else {
                                                print("failed to create event tap")
                                                exit(1)
        }

        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
        CFRunLoopRun()
    }
}

func myCGEventCallback(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
    let keyBoard = event.getIntegerValueField(.keyboardEventKeyboardType)

    var keyboards: [String] = []
    if let keyboardsString = UserDefaults.standard.string(forKey: "Keyboards") {
        keyboards  = keyboardsString.components(separatedBy: ";")
    }
    print(keyboards  )
    guard keyboards.contains("\(keyBoard)") else { return Unmanaged.passRetained(event) }

    if [.keyDown].contains(type) {
        KeyboardEventHandler.shared.ontap(event: event)
    }
    return nil
}
