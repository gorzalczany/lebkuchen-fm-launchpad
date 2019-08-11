import NotificationCenter

enum FM {
    case search(String)
    case query(String)
    case sound(String)
    case vol(Int)
    case skip
    case random

    func execute(){
        let body =
"""
{"item": { "message": { "message": "\(command)" }}}
"""
        Webservice.shared.post(command: body)
        NotificationsHelper.present(message: command)
    }

    private var action: String {
        switch self {
        case .search(_): return "s"
        case .query(_): return "q"
        case .sound(_): return "x"
        case .vol(_): return "vol"
        case .skip: return "skip"
        case .random: return "random"
        }
    }

    var value: String {
        switch self {
        case .query(let value), .search(let value), .sound(let value):
            return value
        case .vol(let value):
            return "\(value)"
        case .skip, .random: return ""
        }
    }

    private var command: String {
        return "/fm \(self.action) \(self.value)"
    }
}
