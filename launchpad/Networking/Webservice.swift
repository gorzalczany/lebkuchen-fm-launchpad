import Foundation

class Webservice {
    static let shared = Webservice()

    func post(command: String) {
        var request = URLRequest(url: URL(string: "https://lebkuchen-fm-service-ph05lk.herokuapp.com/commands/hipchat")!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = command.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            //
        }
        task.resume()
    }

    func get() {
        var request = URLRequest(url: URL(string: "https://lebkuchen-fm-service-ph05lk.herokuapp.com/xsounds")!)
        request.setValue("nie warto", forHTTPHeaderField: "x")
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {return}
            let string1 = String(data: data, encoding: String.Encoding.utf8) ?? "Data could not be printed"
            print(string1)
        }
        task.resume()
    }
}
