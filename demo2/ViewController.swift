import UIKit
import SwiftSocket

class ViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    
    let host = "10.3.13.119"
    let port = 9999
    var client: TCPClient?
    //var connected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        client = TCPClient(address: host, port: Int32(port))
        
    }
    
    @IBAction func connectButtonAction() {
        guard let client = client else { return }
        
        switch client.connect(timeout: 10) {
        case .success:
            appendToTextField(string: "Connected to host \(client.address)")
            
        case .failure(let error):
            appendToTextField(string: String(describing: error))
        }
        
    }
    
    @IBAction func readButtonAction() {
        guard let client = client else { return }
        if let response = readResponse(from: client) {
            appendToTextField(string: "response is '\(response)'")
        } else {
            appendToTextField(string: "response is bad")
        }
    
    }
    
    
    private func sendRequest(string: String, using client: TCPClient) -> String? {
        appendToTextField(string: "Sending data ... ")
        
        switch client.send(string: string) {
        case .success:
            return readResponse(from: client)
        case .failure(let error):
            appendToTextField(string: String(describing: error))
            return nil
        }
    }
    
    private func readResponse(from client: TCPClient) -> String? {
        guard let response = client.read(11) else { return nil }
        
        return String(bytes: response, encoding: .utf8)
    }
    
    private func appendToTextField(string: String) {
        print(string)
        textView.text = textView.text.appending("\n\(string)")
    }
    
}
