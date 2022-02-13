//
//  ContentView.swift
//  BLE_Tests
//
//  Created by Todd Rylaarsdam on 2/10/22.
//

import SwiftUI
import UserNotifications

struct ContentView: View {
    @ObservedObject var bleManager = BLEManager()
    
    var body: some View {
        NavigationView {
            VStack {
                Text(bleManager.initialized == true ? "BLE Manager Running" : "Waiting for initialization...").font(.title2)
                    .padding()
                HStack {
                    if(bleManager.connected) {
                        Button(action: {
                            bleManager.disconnect()
                            bleManager.connected = false
                        }) {
                            Text("Disconnect")
                                .fontWeight(.bold)
                                .foregroundColor(bleManager.connected ? .red : .green)
                                .padding()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(bleManager.connected ? .red : .green, lineWidth: 5)
                                )
                        }
                    }
                    else {
                        Button(action: {
                            bleManager.toggleScanning()
                        }) {
                            Text(bleManager.scanning ? "Stop Scanning" : "Start Scanning")
                                .fontWeight(.bold)
                                .foregroundColor(bleManager.scanning ? .red : .green)
                                .padding()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(bleManager.scanning ? .red : .green, lineWidth: 5)
                                )
                        }
                    }
                }.padding(.bottom)
                Text(bleManager.connected ? "Services List" : "Visible Devices").font(.title2)
                if(bleManager.connected) {
                    List {
                        ForEach(bleManager.discoveredServices, id: \.self) { service in
                            NavigationLink(destination: CharacteristicViewer(service: service).environmentObject(bleManager)) {
                                Text(service.uuid.uuidString)
                            }
                        }
                    }
                }
                else {
                    List {
                        ForEach(bleManager.peripherals) { peripheral in
                            HStack {
                                Text(peripheral.name).bold()
                                Spacer()
                                Button(String(peripheral.rssi)){
                                    bleManager.connect(peripheral: peripheral)
                                }.foregroundColor(.blue)
                            }.padding()
                        }
                    }
                }
            }.navigationBarHidden(true).onAppear() {
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        print("Notifications allowed")
                    } else if let error = error {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
