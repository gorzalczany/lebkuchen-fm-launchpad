import Foundation

enum ParsingError: Error {
    case unknowActionType
}

struct LebkuchenLaunchpadConfig: Codable {

    static private var _shared: LebkuchenLaunchpadConfig?
    static var shared: LebkuchenLaunchpadConfig? {
        get
        {
            return _shared ?? LebkuchenLaunchpadConfig.default
        }
        set {
            _shared = newValue
        }
    }

    static var `default`: LebkuchenLaunchpadConfig? {
        guard let path = Bundle.main.path(forResource: "DefaultLaunchpadConfig", ofType: "json"),
            let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe),
            let config = try? JSONDecoder().decode(LebkuchenLaunchpadConfig.self, from: data)
            else { return nil }
        return config
    }

    let applicationURL: URL
    let keyMapping: [KeyMap]
}

struct KeyMap: Codable {
    let key: String
    let action: FM

    enum CodingKeys: String, CodingKey {
        case key
        case action
        case value
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        key = try values.decode(String.self, forKey: .key)
        let value = try values.decode(String.self, forKey: .value)
        let action = try values.decode(String.self, forKey: .action)

        switch action {
        case "SOUND":
            self.action = .sound(value)
        case "SEARCH":
            self.action = .search(value)
        case "QUERY":
            self.action = .query(value)
        case "RANDOM":
            self.action = .random
        case "SKIP":
            self.action = .skip
        case "VOL":
            self.action = .vol(Int(value) ?? 100)
        default:
            throw ParsingError.unknowActionType
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(action.value, forKey: .value)
        try container.encode(action.codingKey, forKey: .action)
        try container.encode(key, forKey: .key)
    }
}

extension FM {
    var codingKey: String {
        switch self {
        case .sound(_): return "SOUND"
        case .query: return "QUERY"
        case .search(_): return "SEARCH"
        case .random: return "RANDOM"
        case .vol: return "VOL"
        case .skip: return "SKIP"
        }
    }
}
