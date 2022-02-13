//
//  CharacteristicViewer.swift
//  BLE_Tests
//
//  Created by Todd Rylaarsdam on 2/10/22.
//

import SwiftUI
import CoreBluetooth

struct CharacteristicViewer: View {
    @EnvironmentObject var bleManager: BLEManager
    
    var service: CBService
    var body: some View {
        NavigationView {
            VStack {
                Text(service.uuid.uuidString).font(.title2)
                List {
                    ForEach(service.characteristics ?? [CBCharacteristic](), id: \.self) { characteristic in
                        NavigationLink (destination: CharacteristicEditor(characteristic: characteristic).environmentObject(bleManager)) {
                            Text(characteristic.uuid.uuidString)
                        }
                    }
                }
            }
        }.navigationBarTitleDisplayMode(.inline).navigationTitle("")
    }
}
