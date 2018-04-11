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
    
    var id = ""
    let host = "10.0.0.216"
    let port = 9990
    let socket = try? Socket.create()
    let myConfig = SSLService.Configuration()
    
    var streamFlag = false
    
    override func viewDidLoad() {
        appendToTextField(string: id)
        super.viewDidLoad()
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
        }
    }
    
    @IBAction func
        connectButtonAction() {
            guard let client = socket else { return }
            updateGraph()
            do {
                try client.connect(to: host, port: Int32(port), timeout: 10)
                appendToTextField(string: "Connected to host \(host) on port \(port)")
                DispatchQueue.global(qos: .background).async {
                    self.streamData()
                }
            } catch {
                appendToTextField(string: "Cannot connect to host")
            }
            
        }
    
    
    @IBAction func readButtonAction() {
        streamFlag = !streamFlag
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
        while true {
            if streamFlag {
                let header = readHeader()
                readData(flag: header.flag, count: header.count)
                
                DispatchQueue.main.async {
                    self.updateGraph()
                }
            }
        }
    }
    
    func updateGraph(){
        
        var lineChartEntry  = [ChartDataEntry]() //this is the Array that will eventually be displayed
        
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
        let response = readResponse(count: 16)
        let test = response!.reduce("", {$0 + String(format: "%02x", $1)})
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
        switch flag {
        case 0:
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
            
            numbers = new_numbers.map{Double($0)}
            
        default:
            return
        }
    }

}
