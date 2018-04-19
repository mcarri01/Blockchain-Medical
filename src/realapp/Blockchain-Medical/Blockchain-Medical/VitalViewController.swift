//
//  VitalViewController.swift
//  Blockchain-Medical
//
//  Created by Matthew Carrington-Fair on 4/11/18.
//  Copyright © 2018 Ben Francis. All rights reserved.
//

import UIKit
import Socket
import Charts
import SSLService

class VitalViewController: UIViewController {

    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var chtChart: LineChartView!
    var numbers : [Double] = [  ]
    
    var HR : [Double] = [  ]
    var ECG : [Double] = [  ]
    var temp : [Double] = [  ]
    var DB : [Double] = [  ]
    var pleth : [Double] = [  ]
    var resp : [Double] = [  ]
    var oxy : [Double] = [  ]
    var SB : [Double] = [  ]
    
    
    var id = ""
    let host = "10.3.13.119"
    let port = 9990
    let socket = try? Socket.create()
    let myConfig = SSLService.Configuration()
    
    var streamFlag = false
    
    let vitalDict: [String: String] = ["0": "Heart Rate", "1": "ECG", "2": "Temperature", "3": "Diastolic Blood", "4": "Plethysmograph", "5": "Respiration", "6": "Oxygen", "7": "Systolic Blood"]
    
    override func viewDidLoad() {
        //appendToTextField(string: id)
        super.viewDidLoad()
        self.title = vitalDict[id]
        guard let socket = socket else {
            return
        }
        socket.delegate = try! SSLService(usingConfiguration: myConfig)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParentViewController {
            guard let socket = socket else { return }
            socket.close()
            streamFlag = false
            
        }
    }
    
    @IBAction func
        connectButtonAction() {
            guard let client = socket else { return }
            updateGraph()
            do {
                try client.connect(to: host, port: Int32(port), timeout: 10)
                appendToTextField(string: "Connected to host \(host) on port \(port)")
                
            } catch {
                appendToTextField(string: "Cannot connect to host")
            }
            
        }
    
    
    @IBAction func readButtonAction() {
        streamFlag = !streamFlag
        DispatchQueue.global(qos: .background).async {
            self.streamData()
        }
        
    }
    
    private func readResponse(count: Int) -> Data? {
        guard let socket = socket else { return nil }
        let readData = UnsafeMutablePointer<CChar>.allocate(capacity: count)
        let _ = try? socket.read(into: readData, bufSize: count, truncate: true)
        return Data(bytesNoCopy: readData, count: count, deallocator: .none)
    }
    
    private func appendToTextField(string: String) {
        textView.text = textView.text.appending("\n\(string)")
    }
    
    private func streamData() {
        while streamFlag {
            //if streamFlag {
                let count = readHeader()
                print(count)
            
                //appendToTextField(string: String(header.count))
                readData(count: count)
            
                DispatchQueue.main.async {
                    self.updateGraph()
              //  }
            }
        }
    }
    
    func updateGraph(){
        
        var lineChartEntry  = [ChartDataEntry]() //this is the Array that will eventually be displayed
        
//        for i in 0..<numbers.count {
//            let value = ChartDataEntry(x: Double(i), y: numbers[i]) // here we set the X and Y status in a data chart entry
//            lineChartEntry.append(value) // here we add it to the data set
//        }
        
        var graphData : [Double] = [  ]
        switch vitalDict[id] {
        case "Heart Rate":
            graphData = HR
        case "ECG":
            graphData  = ECG
        case "Temperature":
            graphData = temp
        case "Diastolic Blood":
            graphData = DB
        case "Plethysmograph":
            graphData = pleth
        case "Respiration":
            graphData = resp
        case "Oxygen":
            graphData = oxy
        case "Systolic":
            graphData = SB
        default:
            graphData = HR
        }
        
          for i in 0..<graphData.count {
              let value = ChartDataEntry(x: Double(i), y: graphData[i]) // here we set the X and Y status in a data chart entry
              lineChartEntry.append(value) // here we add it to the data set
          }
        let line1 = LineChartDataSet(values: lineChartEntry, label: "Number") //Here we convert lineChartEntry to a LineChartDataSet
        line1.colors = [NSUIColor.blue] //Sets the colour to blue
        
        let data = LineChartData() //This is the object that will be added to the chart
        data.addDataSet(line1) //Adds the line to the dataSet
        
        chtChart.data = data //finally - it adds the chart data to the chart and causes an update
        //chtChart.chartDescription?.text = "My awesome chart" // Here we set the description for the graph
    }
    
    func readHeader() -> Int {
        let response = readResponse(count: 12)
        let test = response!.reduce("", {$0 + String(format: "%02x", $1)})
        let header_arr_try = try? unpack("!8sI", unhexlify(test)!)
        guard let header_arr = header_arr_try else {
            return -1
        }
        
        if header_arr[0] as? String == "forkpork" {
            let count = header_arr[1] as! Int
            return count
        } else {
            return 0
        }
        
    }
    
    func readData(count: Int) {
            let response = readResponse(count: count*4)
            let test = response!.reduce("", {$0 + String(format: "%02x", $1)})
            let data_arr_try = try? unpack("! " + String(count) + "I", unhexlify(test)!)
            guard let data_arr = data_arr_try else {
                return
            }
            var new_numbers: [Int] = []
            for num in data_arr {
                new_numbers.append(num as! Int)
            }
            HR.append(Double(new_numbers[0]))
            ECG.append(Double(new_numbers[1]))
            temp.append(Double(new_numbers[2]))
            DB.append(Double(new_numbers[3]))
            pleth.append(Double(new_numbers[4]))
            resp.append(Double(new_numbers[5]))
            oxy.append(Double(new_numbers[6]))
            SB.append(Double(new_numbers[7]))
        
        
            //numbers = new_numbers.map{Double($0)}
        
    }

}
