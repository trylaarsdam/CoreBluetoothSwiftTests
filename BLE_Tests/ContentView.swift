//
//  ContentView.swift
//  BLE_Tests
//
//  Created by Todd Rylaarsdam on 2/10/22.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var bleManager = BLEManager()
    
    var body: some View {
        VStack {
            Text(bleManager.initialized == true ? "BLE Manager Initialized" : "Waiting for initialization").font(.title2)
                .padding()
            HStack {
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
                if(bleManager.connected) {
                    Button(action: {
                        bleManager.disconnect()
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
            }.padding(.bottom)
            if(bleManager.connected) {
                Text("Services List").font(.title2)
                List {
                    ForEach(bleManager.discoveredServices, id: \.self) { service in
                        Text(service.uuid.uuidString)
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
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
