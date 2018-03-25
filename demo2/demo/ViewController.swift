import UIKit
import SwiftSocket
import Charts


class ViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var chtChart: LineChartView!
    
    var numbers : [Double] = [  ]
    
    let host = "10.0.0.216"
    let port = 9995
    var client: TCPClient?
    var streamFlag = false
    //var connected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        client = TCPClient(address: host, port: Int32(port))
        
        
    }
    
    /*
     keyword
     
     
     (flag) what data is coming in
 
 
 
     */
    
    
    @IBAction func connectButtonAction() {
        
        let d = pack("<h2I3sf", [1, 2, 3, "asd", 0.5])
        assert(d == unhexlify("0100 02000000 03000000 617364 0000003f"))
        
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
    
    
//    private func sendRequest(string: String, using client: TCPClient) -> String? {
//        appendToTextField(string: "Sending data ... ")
//
//        switch client.send(string: string) {
//        case .success:
//            return readResponse(from: client)
//        case .failure(let error):
//            appendToTextField(string: String(describing: error))
//            return nil
//        }
//    }
    
    private func readResponse(from client: TCPClient, count: Int) -> String? {
        guard let response = client.read(count) else { return nil }
        return String(bytes: response, encoding: .utf8)
        //let header_arr_try = try? unpack("!8sII", unhexlify(header!)!)
        
    }
    
    private func appendToTextField(string: String) {
        print(string)
        textView.text = textView.text.appending("\n\(string)")
    }
    
    
    private func streamData() {
        //guard let client = client else { return }
        while true {
            
            if streamFlag {
                //var toAppend = ""
                let header = readHeader()
                    
                //numbers.append(Double(response)!)
                //updateGraph()
                //toAppend = "response is '\(response)'"
                
                readData(flag: header.flag, count: header.count)
                
                DispatchQueue.main.async {
                //    self.appendToTextField(string: toAppend)
                    self.updateGraph()
                }
                 /*else {
                    toAppend = "response is bad"
                }*/
//                DispatchQueue.main.async {
//                    self.appendToTextField(string: toAppend)
//                }
            }
        }
    }
    
    func updateGraph(){
        
        var lineChartEntry  = [ChartDataEntry]() //this is the Array that will eventually be displayed on the graph.
        

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
    
    
    func readHeader() -> (flag: Int, count: Int){
        guard let client = client else { return (-1, -1) }
        //let header = readResponse(from: client, count: 16)
        guard let response = client.read(16) else { return (-1, -1)}
        let test = response.reduce("", {$0 + String(format: "%02x", $1)})
        print(test)
        let header_arr_try = try? unpack("!8sII", unhexlify(test)!)
        guard let header_arr = header_arr_try else {
            return (-1, -1)
        }
        
        if header_arr[0] as? String == "tomsucks" {
            let flag = header_arr[1] as! Int
            let count = header_arr[2] as! Int
            return (flag, count)
        } else {
            return (0,0)
        }
        
    }
    
    func readData(flag: Int, count: Int) {
        guard let client = client else { return }
        
        switch flag {
        case 0:
            //let response = readResponse(from: client, count: count*4)
            guard let response = client.read(count*4) else { return}
            let test = response.reduce("", {$0 + String(format: "%02x", $1)})
            let data_arr_try = try? unpack("! " + String(count) + "I", unhexlify(test)!)
            guard let data_arr = data_arr_try else {
                return
            }
            print(data_arr)
            var new_numbers: [Int] = []
            for num in data_arr {
                new_numbers.append(num as! Int)
            }
            
            numbers = new_numbers.map{Double($0)}
            
            
           
            
            
        default:
            return
        }
        
    }
    
    
}
