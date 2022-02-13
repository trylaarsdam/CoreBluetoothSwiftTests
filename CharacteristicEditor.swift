//
//  CharacteristicEditor.swift
//  BLE_Tests
//
//  Created by Todd Rylaarsdam on 2/10/22.
//

import SwiftUI
import CoreBluetooth

extension Data {
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }

    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return self.map { String(format: format, $0) }.joined()
    }
}

struct CharacteristicEditor: View {
    @EnvironmentObject var bleManager: BLEManager

    var characteristic: CBCharacteristic
    var body: some View {
        Form {
            Section ("Characteristic Value"){
                Text("String: \(String(data: bleManager.characteristicValues[characteristic.uuid.uuidString] ?? "No Data".data(using: String.Encoding.utf8)!, encoding: .utf8) ?? "Data does not convert to ASCII")")
                Text("Hex: 0x\(bleManager.characteristicValues[characteristic.uuid.uuidString]?.hexEncodedString(options: .upperCase) ?? "")")
            }
            Section ("Characteristic Details") {
                Text(characteristic.isNotifying ? "Is Notifying" : "Is not notifying")
                Text("Raw info: \(characteristic.description)")
            }
        }.navigationBarTitleDisplayMode(.inline).navigationTitle(characteristic.uuid.uuidString)
            .onAppear() {
                bleManager.readValueForCharacteristic(characteristic: characteristic)
            }
    }
}
