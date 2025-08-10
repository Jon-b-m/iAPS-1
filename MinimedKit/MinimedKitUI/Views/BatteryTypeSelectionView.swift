import LoopKitUI
import MinimedKit
import SwiftUI

struct BatteryTypeSelectionView: View {
    @Binding var batteryType: BatteryChemistryType

    var body: some View {
        VStack {
            List {
                Section {
                    Text(LocalizedString(
                        "Choose the type of battery you are using in your pump for better alerting about low battery conditions.",
                        comment: "Instructions on selecting battery chemistry type"
                    ))
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.vertical, 10)
                }
                Picker("Battery Chemistry", selection: $batteryType) {
                    ForEach(BatteryChemistryType.allCases, id: \.self) { batteryType in
                        Text(batteryType.description)
                    }
                }
                .pickerStyle(.inline)
            }
        }
        .insetGroupedListStyle()
        .navigationTitle(LocalizedString("Pump Battery Type", comment: "navigation title for pump battery type selection"))
    }
}
