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
import FirebaseAuth
import Firestore

class VitalViewController: UIViewController {

    @IBOutlet weak var averageLabelView: UILabel!
    @IBOutlet weak var labelView: UILabel!
    //@IBOutlet weak var textView: UITextView!
    @IBOutlet weak var chtChart: LineChartView!
    var numbers : [Double] = [  ]
    var gettingPoints = true
    @IBOutlet weak var connectBar: UIProgressView!
    
    
    @IBOutlet weak var readButton: UIButton!
    
    
    var HR : [Double] = [  ]
    var ECG : [Double] = [  ]
    var temp : [Double] = [  ]
    var DB : [Double] = [  ]
    var pleth : [Double] = [  ]
    var resp : [Double] = [  ]
    var oxy : [Double] = [  ]
    var SB : [Double] = [  ]
    
    var readBuffer: [Double] = []
    var ecgBuffer: [Double] = [ ]
    
    var masterPoints: [Double] = []
    var averages: [Double] = []
    var averageSet = false
    
    var dsp = DSP()
    
    var id = ""
    let host = "10.3.13.119"
    let port = 9990
    let socket = try? Socket.create()
    let myConfig = SSLService.Configuration()
    
    var streamFlag = false
    
    let vitalDict: [String: String] = ["0": "Heart Rate", "1": "ECG", "2": "Temperature", "3": "Diastolic Blood", "4": "Plethysmograph", "5": "Respiration", "6": "Oxygen", "7": "Systolic Blood"]
    let scaleDict: [String: (Double, Double)] = ["0": (0, 0), "1": (-0.01, 1.065), "2": (0, 1), "3": (54, 90), "4": (0.891, 3.07), "5": (0, 1), "6": (0, 1), "7": (90, 139)]
    
    override func viewDidLoad() {
        //appendToTextField(string: id)
        
        readButton.isHidden = true
        
        
        super.viewDidLoad()
        self.title = vitalDict[id]
        guard let socket = socket else {
            return
        }
        
        
        socket.delegate = try! SSLService(usingConfiguration: myConfig)
        
        
        
        //guard let client = socket else { return }
        updateGraph()
        

        DispatchQueue.main.async {
            usleep(125000)
            self.connectBar.setProgress(0.0, animated: true)
            usleep(125000)
            self.connectBar.setProgress(0.25, animated: true)
            usleep(125000)
            self.connectBar.setProgress(0.5, animated: true)
            usleep(125000)
            self.connectBar.setProgress(0.75, animated: true)
            usleep(125000)
            self.connect()
            self.connectBar.setProgress(1.0, animated: true)
        }
        grabAverages(type: vitalDict[id]!)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParentViewController {
            guard let socket = socket else { return }
            socket.close()
            streamFlag = false
            
        }
    }
    

    
    
    @IBAction func readButtonAction() {
        connectBar.setProgress(0, animated: false)
        streamFlag = !streamFlag
        DispatchQueue.global(qos: .background).async {
            self.streamData()
        }
        
    }
    
    private func connect() {
        guard let socket = socket else { return }
        var connected = false
        
        while (!connected) {
            sleep(2)
            do {
                try socket.connect(to: host, port: Int32(port), timeout: 10)
                
                appendToTextField(string: "Connected!")
                //appendToTextField(string: "Connected to host \(host) on port \(port)")
                connected = true
                updateGraph()
                self.readButton.isHidden = false
            } catch {
                //appendToTextField(string: "Connecting...")
                appendToTextField(string: "OOPSIE WOOPSIE!! Uwu We made a fucky wucky!! A wittle fucko boingo! The code monkeys at our headquarters are working VEWY HAWD to fix this!")
                
            }
        }

    }
    
    
    private func readResponse(count: Int) -> Data? {
        guard let socket = socket else { return nil }
        let readData = UnsafeMutablePointer<CChar>.allocate(capacity: count)
        let _ = try? socket.read(into: readData, bufSize: count, truncate: true)
        return Data(bytesNoCopy: readData, count: count, deallocator: .none)
    }
    
    private func appendToTextField(string: String) {
        labelView.text = string
    }
    
    private func streamData() {
        while streamFlag {
            //if streamFlag {
                let count = readHeader()
                print(count)
            
                //appendToTextField(string: String(header.count))
                readData(count: count)
            
                DispatchQueue.main.async {
                    self.appendToTextField(string: "Reading data...")
                    self.updateGraph()
              //  }
            }
        }
    }
    
    func grabAverages(type: String) {
        let db = Firestore.firestore()
        _ = db.collection("vitals").whereField("type", isEqualTo: type).whereField("senderId", isEqualTo: user).getDocuments {
            (querySnapshot, error) in
            if let documents = querySnapshot?.documents {
                self.averages = []
                for document in documents {
                    print("adding an average")
                    let data = document.data()
                    self.averages.append(data["average"] as! Double)
                }
                self.updateGraph()
            } else {
                print("Error fetching documents: \(String(describing: error))")
                return
   
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
//        case "Heart Rate"?:
//            graphData = HR
        case "ECG"?:
            if ECG.count != 0 {
                let ECGSlice: ArraySlice<Double> = ECG[5..<100]
                graphData  = Array(ECGSlice)
            } else {
                graphData = ECG
            }
            chtChart.leftAxis.axisMaximum = 500
            chtChart.rightAxis.axisMaximum = 500
            chtChart.leftAxis.axisMinimum = -500
            chtChart.rightAxis.axisMinimum = -500
        case "Temperature"?:
            graphData = self.averages
            print(graphData)
            chtChart.leftAxis.axisMaximum = 110
            chtChart.rightAxis.axisMaximum = 110
            chtChart.leftAxis.axisMinimum = 70
            chtChart.rightAxis.axisMinimum = 70
        case "Diastolic Blood"?:
   
            graphData = self.averages
            print(graphData)
            chtChart.leftAxis.axisMaximum = 100
            chtChart.rightAxis.axisMaximum = 100
            chtChart.leftAxis.axisMinimum = 50
            chtChart.rightAxis.axisMinimum = 50
        case "Plethysmograph"?:
            
            graphData = self.averages
            print(graphData)
            chtChart.leftAxis.axisMaximum = 5
            chtChart.rightAxis.axisMaximum = 5
            chtChart.leftAxis.axisMinimum = 0
            chtChart.rightAxis.axisMinimum = 0
        case "Respiration"?:
          
            graphData = self.averages
            print(graphData)
            chtChart.leftAxis.axisMaximum = 2
            chtChart.rightAxis.axisMaximum = 2
            chtChart.leftAxis.axisMinimum = -1
            chtChart.rightAxis.axisMinimum = -1
        case "Oxygen"?:
      
            graphData = self.averages
            print(graphData)
            chtChart.leftAxis.axisMaximum = 110
            chtChart.rightAxis.axisMaximum = 110
            chtChart.leftAxis.axisMinimum = 90
            chtChart.rightAxis.axisMinimum = 90
        case "Systolic"?:
           
            graphData = self.averages
            print(graphData)
            chtChart.leftAxis.axisMaximum = 150
            chtChart.rightAxis.axisMaximum = 150
            chtChart.leftAxis.axisMinimum = 80
            chtChart.rightAxis.axisMinimum = 80
        default:
           
            graphData = self.averages
            print(graphData)
            chtChart.leftAxis.axisMaximum = 100
            chtChart.rightAxis.axisMaximum = 100
            chtChart.leftAxis.axisMinimum = -100
            chtChart.rightAxis.axisMinimum = -100
        }
        
          for i in 0..<graphData.count {
              let value = ChartDataEntry(x: Double(i), y: graphData[i]) // here we set the X and Y status in a data chart entry
              lineChartEntry.append(value) // here we add it to the data set
          }
        var line1 = LineChartDataSet(values: lineChartEntry, label: "Number") //Here we convert lineChartEntry to a LineChartDataSet
        if vitalDict[id] == "ECG" {
            line1.drawCirclesEnabled = false
        }
        line1.drawValuesEnabled = false
        
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
            //HR.append(Double(new_numbers[0]))
            //ecgBuffer.append(Double(new_numbers[1]))
        print(Int(id)!)
        readBuffer.append(Double(new_numbers[Int(id)!]))
//            temp.append(Double(new_numbers[2]))
//            DB.append(Double(new_numbers[3]))
//            pleth.append(Double(new_numbers[4]))
//            resp.append(Double(new_numbers[5]))
//            oxy.append(Double(new_numbers[6]))
//            SB.append(Double(new_numbers[7]))
        

        switch vitalDict[id] {
        case "ECG"?:
            if self.gettingPoints {
                DispatchQueue.main.async {
                    self.connectBar.setProgress(Float(Double(self.readBuffer.count) / 128), animated: true)
                }
            }
            if readBuffer.count == 128 {
                self.gettingPoints = false
    //            DispatchQueue.main.async {
    //                self.connectBar.setProgress(1, animated: true)
    //            }
                ecgBuffer = dsp.highPassFilter(input: readBuffer, cutoff: 7.5)
                
                ecgBuffer = dsp.lowPassFilter(input: ecgBuffer, cutoff: 25.0)
                ecgBuffer = dsp.lowPassFilter(input: ecgBuffer, cutoff: 25.0)
                ecgBuffer = dsp.lowPassFilter(input: ecgBuffer, cutoff: 25.0)
                print(ecgBuffer.count)
                ecgBuffer = ecgBuffer.filter {abs($0) > 2  }
                //let ecgBuf: ArraySlice<Double> = ecgBuffer[82..<244]
                print(ecgBuffer.count)
                let bufslice: ArraySlice<Double> = ecgBuffer[(ecgBuffer.count - 2)..<(ecgBuffer.count)]
                masterPoints = masterPoints + Array(bufslice)
                ECG = ECG + ecgBuffer
                ecgBuffer = []
                //readBuffer.remove(at: 0)
                for _ in 0...2 {
                    readBuffer.remove(at: 0)
                }
            }
    //        if ecgBuffer.count == 128 {
    //            ecgBuffer = dsp.highPassFilter(input: ecgBuffer, cutoff: 7.5)
    //
    //            ecgBuffer = dsp.lowPassFilter(input: ecgBuffer, cutoff: 25.0)
    //            ecgBuffer = dsp.lowPassFilter(input: ecgBuffer, cutoff: 25.0)
    //            ecgBuffer = dsp.lowPassFilter(input: ecgBuffer, cutoff: 25.0)
    //            ecgBuffer = ecgBuffer.filter {abs($0) > 2  }
    //            ECG = ECG + ecgBuffer
    //            ecgBuffer = []
    //        }
    //
            while ECG.count > 128 {
                ECG.remove(at: 0)
            }
            if masterPoints.count >= 384 {
                self.streamFlag = false
                guard let socket = self.socket else { return }
                socket.close()
                DispatchQueue.main.async {
                    self.appendToTextField(string: "Finished reading data!")
                }
                let db = Firestore.firestore()
                db.collection("vitals").addDocument(data:
                    ["type": self.vitalDict[self.id],
                     "data": self.masterPoints,
                     "senderId": user,
                     "date": Date()]) { err in
                        if let err = err {
                            print("Error adding document: \(err)")
                        } else {
                            print("Document added successfully")
                        }
                        
                        
                }
            }
        default:
            if self.gettingPoints {
                DispatchQueue.main.async {
                    self.connectBar.setProgress(Float(Double(self.readBuffer.count) / 384), animated: true)
                }
            }
            if readBuffer.count >= 384 {
                print(readBuffer)
                self.gettingPoints = false
                self.streamFlag = false
                guard let socket = self.socket else { return }
                socket.close()
                let (scaleMin, scaleMax) = scaleDict[id]!
                let min = readBuffer.min()
                let max = readBuffer.max()
                var total = 0.0
                var average = 0.0
                if Int(id) != 2 {
                    masterPoints = readBuffer.map { (($0 - min!) / (max!-min!)) }
                    masterPoints = masterPoints.map { $0 * (scaleMax - scaleMin) + scaleMin }
                    total = masterPoints.reduce (0, {$0 + $1})
                    average = total / Double(masterPoints.count)
                } else {
                    total = readBuffer.reduce(0, {$0 + $1})
                    average = total / Double(readBuffer.count)
                }
                print(average)
                DispatchQueue.main.async {
                    self.appendToTextField(string: "Finished reading data!")
                    self.averageLabelView.text = self.averageLabelView.text! + " " + String(average)
                }
                let db = Firestore.firestore()
                db.collection("vitals").addDocument(data:
                    ["type": self.vitalDict[self.id],
                     "data": self.masterPoints,
                     "senderId": user,
                     "date": Date(),
                     "average": average]) { err in
                        if let err = err {
                            print("Error adding document: \(err)")
                        } else {
                            print("Document added successfully")
                        }
                        
                        
                }
            }
            
        
        
        
        

        
    }
    }

}
