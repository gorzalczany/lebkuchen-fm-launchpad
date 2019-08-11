import Foundation

class KeyboardEventHandler {
    static let shared = KeyboardEventHandler()

    private init() {
        setup()
    }

    func ontap(event: CGEvent) {
        //let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
        //print("\(event.flags) + \(keyCode)")
        // better use event.flags and keycode instead of converting it 2 unichar
        // that way we can use more macro layers
        var uniChar = UniChar()
        var length = 0
        event.keyboardGetUnicodeString(maxStringLength: 1, actualStringLength: &length, unicodeString: &uniChar)

        if let uniScalar = UnicodeScalar(uniChar) {
            let char = Character(uniScalar)
            let config = LebkuchenLaunchpadConfig.shared
            let keyMap = config?.keyMapping.first(where: { $0.key == String(char) })
            keyMap?.action.execute()
        } else {
            print("illegal input")
        }
    }
}
