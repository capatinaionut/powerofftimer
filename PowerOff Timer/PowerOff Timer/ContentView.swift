//
//  ContentView.swift
//  PowerOff Timer
//
//  Created by Capatina Ionut on 13.01.2024.
//
//

import SwiftUI
import AVFoundation
import Cocoa

class ExecuteAppleScript {

    var status = ""

    private let scriptfileUrl : URL?


    init() {
        do {
            let destinationURL = try FileManager().url(
                for: FileManager.SearchPathDirectory.applicationScriptsDirectory,
                in: FileManager.SearchPathDomainMask.userDomainMask,
                appropriateFor:nil,
                create: true)

            self.scriptfileUrl = destinationURL.appendingPathComponent("PowerOffScript.scpt")
            self.status = "Linking of scriptfile successful!"

        } catch {
            self.status = error.localizedDescription
            self.scriptfileUrl = nil
        }
    }

    func execute() -> String {
        do {
            let _: Void = try NSUserScriptTask(url: self.scriptfileUrl!).execute()
            self.status = "Execution of AppleScript successful!"
        } catch {
            self.status = error.localizedDescription
        }
        
        return self.status
    }
}

struct ContentView: View {
    @State var command1 = "-h"
    @State var timp = 0
    @State var timpsetat = 0.0
    @State var currentDate = Date.now.formatted()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var timeRemaining = 0
    @State var dataSetata = Date()
    @State var status = ""
    //
    
    var body: some View {
        VStack{
            Spacer()
            Text("Set minutes until shutdown").font(.title)
            Text("\(timpsetat.formatted()) minutes").foregroundColor(.green)
            Slider(value: $timpsetat, in: 0...240,step: 1)
            HStack{
                Text("0").font(.headline).foregroundColor(.yellow)
                Spacer()
                Text("240").font(.headline).foregroundColor(.red)
            }
            Button {
                timp = Int(timpsetat)           //set timer
                dataSetata =  Date().addingTimeInterval(TimeInterval(timp * 60))
                timeRemaining = Int(timpsetat * 60)
            }label: {
                Text("Shutdown").foregroundColor(.black)
            }.buttonStyle(.borderedProminent).cornerRadius(5).padding()
            Spacer()
            if(timp != 0){
                VStack{
                    Text("ARMED").font(.title).foregroundColor(.red)
                    Text("Your computer will shutdown at \(dataSetata)").foregroundColor(.red)
                        .onReceive(self.timer) { _ in           //timer run....
                            if((Date() > dataSetata)&&(timp != 0)) {    //timer condition to stop
                               /*
                                command1 =  "tell application \"System Events\"\nshut down\nend tell"   //set command
                                DispatchQueue.global(qos: .userInitiated).async {   //run script to shutdown pc after time condition
                                    let script = NSAppleScript(source: command1)
                                     script?.executeAndReturnError(nil)
                                }
                                print("executed")
                                timp = 0    //set timer to 0
                                */
                                DispatchQueue.global(qos: .userInteractive).async {
                                    self.status = ExecuteAppleScript().execute()
                                    DispatchQueue.main.async {
                                        // Update the UI on the main thread
                                    }
                                }
                            }
                        }
                }
            }
        }.padding()
    }
}

#Preview {
    ContentView()
}
