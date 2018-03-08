import UIKit
import SwiftSocket
import Charts

class ViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var chtChart: LineChartView!
    
    var numbers : [Double] = [  ]
    
    let host = "10.0.0.93"
    let port = 9998
    var client: TCPClient?
    var streamFlag = false
    //var connected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        client = TCPClient(address: host, port: Int32(port))
        
        
    }
    
    @IBAction func connectButtonAction() {
        guard let client = client else { return }
        updateGraph()
        switch client.connect(timeout: 10) {
        case .success:
            appendToTextField(string: "Connected to host \(client.address)")
            DispatchQueue.global(qos: .background).async {
                self.streamData()
            }
            

        case .failure(let error):
            appendToTextField(string: String(describing: error))
            appendToTextField(string: "wee")
        }
        
    }
    
    @IBAction func readButtonAction() {
        streamFlag = !streamFlag
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
        guard let response = client.read(1) else { return nil }
        return String(bytes: response, encoding: .utf8)
    }
    
    private func appendToTextField(string: String) {
        print(string)
        textView.text = textView.text.appending("\n\(string)")
    }
    
    
    private func streamData() {
        guard let client = client else { return }
        while true {
            
            if streamFlag {
                var toAppend = ""
                if let response = readResponse(from: client) {
                    numbers.append(Double(response)!)
                    //updateGraph()
                    toAppend = "response is '\(response)'"
                    
                    
                    DispatchQueue.main.async {
                        self.appendToTextField(string: toAppend)
                        self.updateGraph()
                    }
                } /*else {
                    toAppend = "response is bad"
                }*/
//                DispatchQueue.main.async {
//                    self.appendToTextField(string: toAppend)
//                }
            } else {
                print("not reading")
            }
        }
    }
    
    func updateGraph(){
        
        var lineChartEntry  = [ChartDataEntry]() //this is the Array that will eventually be displayed on the graph.
        
        print("hereer")
        //here is the for loop
        for i in 0..<numbers.count {
            
            let value = ChartDataEntry(x: Double(i), y: numbers[i]) // here we set the X and Y status in a data chart entry
            lineChartEntry.append(value) // here we add it to the data set
        }
        
        let line1 = LineChartDataSet(values: lineChartEntry, label: "Number") //Here we convert lineChartEntry to a LineChartDataSet
        line1.colors = [NSUIColor.blue] //Sets the colour to blue
        
        let data = LineChartData() //This is the object that will be added to the chart
        data.addDataSet(line1) //Adds the line to the dataSet
        
        
        chtChart.data = data //finally - it adds the chart data to the chart and causes an update
        chtChart.chartDescription?.text = "My awesome chart" // Here we set the description for the graph
    }
    
    
}
