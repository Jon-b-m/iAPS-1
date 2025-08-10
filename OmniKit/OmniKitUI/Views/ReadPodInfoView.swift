import LoopKit
import OmniKit
import SwiftUI

struct ReadPodInfoView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var title: String // e.g., "Read Pulse Log"
    var actionString: String // e.g., "Reading Pulse Log..."
    var failedString: String // e.g., "Failed to read pulse log."

    var action: () async throws -> String

    @State private var alertIsPresented: Bool = false
    @State private var displayString: String = ""
    @State private var error: Error? = nil
    @State private var executing: Bool = false
    @State private var showActivityView: Bool = false

    var body: some View {
        VStack {
            List {
                Section {
                    let myFont = Font
                        .system(size: 12)
                        .monospaced()
                    Text(self.displayString)
                        .font(myFont)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        self.showActivityView = true
                    }) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }.sheet(isPresented: $showActivityView) {
                ActivityView(isPresented: $showActivityView, activityItems: [self.displayString])
            }
            VStack {
                Button(action: {
                    Task { @MainActor in
                        await attemptAction()
                    }
                }) {
                    Text(buttonText)
                        .actionButtonStyle(.primary)
                }
                .padding()
                .disabled(executing)
            }
            .padding(self.horizontalSizeClass == .regular ? .bottom : [])
            .background(Color(UIColor.secondarySystemGroupedBackground).shadow(radius: 5))
        }
        .insetGroupedListStyle()
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $alertIsPresented, content: { alert(error: error) })
        .task {
            await attemptAction()
        }
    }

    private func attemptAction() async {
        executing = true
        displayString = ""
        do {
            displayString = try await action()
        } catch {
            displayString = ""
            self.error = error
            alertIsPresented = true
        }
        executing = false
    }

    private var buttonText: String {
        if executing {
            return actionString
        } else {
            return title
        }
    }

    private func alert(error: Error?) -> SwiftUI.Alert {
        SwiftUI.Alert(
            title: Text(failedString),
            message: Text(error?.localizedDescription ?? "No Error")
        )
    }
}

struct ReadPodInfoView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ReadPodInfoView(
                title: "Read Pulse Log",
                actionString: "Reading Pulse Log...",
                failedString: "Failed to read pulse log"
            ) {
                let podInfoPulseLogRecent = try! PodInfoPulseLogRecent(encodedData: Data([
                    0x50,
                    0x03,
                    0x17,
                    0x39,
                    0x72,
                    0x58,
                    0x01,
                    0x3C,
                    0x72,
                    0x43,
                    0x01,
                    0x41,
                    0x72,
                    0x5A,
                    0x01,
                    0x44,
                    0x71,
                    0x47,
                    0x01,
                    0x49,
                    0x51,
                    0x59,
                    0x01,
                    0x4C,
                    0x51,
                    0x44,
                    0x01,
                    0x51,
                    0x73,
                    0x59,
                    0x01,
                    0x54,
                    0x50,
                    0x43,
                    0x01,
                    0x59,
                    0x50,
                    0x5A,
                    0x81,
                    0x5C,
                    0x51,
                    0x42,
                    0x81,
                    0x61,
                    0x73,
                    0x59,
                    0x81,
                    0x00,
                    0x75,
                    0x43,
                    0x80,
                    0x05,
                    0x70,
                    0x5A,
                    0x80,
                    0x08,
                    0x50,
                    0x44,
                    0x80,
                    0x0D,
                    0x50,
                    0x5B,
                    0x80,
                    0x10,
                    0x75,
                    0x43,
                    0x80,
                    0x15,
                    0x72,
                    0x5E,
                    0x80,
                    0x18,
                    0x73,
                    0x45,
                    0x80,
                    0x1D,
                    0x72,
                    0x5B,
                    0x00,
                    0x20,
                    0x70,
                    0x43,
                    0x00,
                    0x25,
                    0x50,
                    0x5C,
                    0x00,
                    0x28,
                    0x50,
                    0x46,
                    0x00,
                    0x2D,
                    0x50,
                    0x5A,
                    0x00,
                    0x30,
                    0x75,
                    0x47,
                    0x00,
                    0x35,
                    0x72,
                    0x59,
                    0x00,
                    0x38,
                    0x70,
                    0x46,
                    0x00,
                    0x3D,
                    0x75,
                    0x57,
                    0x00,
                    0x40,
                    0x72,
                    0x43,
                    0x00,
                    0x45,
                    0x73,
                    0x55,
                    0x00,
                    0x48,
                    0x73,
                    0x41,
                    0x00,
                    0x4D,
                    0x70,
                    0x52,
                    0x00,
                    0x50,
                    0x73,
                    0x3F,
                    0x00,
                    0x55,
                    0x74,
                    0x4D,
                    0x00,
                    0x58,
                    0x72,
                    0x3D,
                    0x80,
                    0x5D,
                    0x73,
                    0x4D,
                    0x80,
                    0x60,
                    0x71,
                    0x3D,
                    0x80,
                    0x01,
                    0x51,
                    0x50,
                    0x80,
                    0x04,
                    0x72,
                    0x3D,
                    0x80,
                    0x09,
                    0x50,
                    0x4E,
                    0x80,
                    0x0C,
                    0x51,
                    0x40,
                    0x80,
                    0x11,
                    0x74,
                    0x50,
                    0x80,
                    0x14,
                    0x71,
                    0x40,
                    0x80,
                    0x19,
                    0x50,
                    0x4D,
                    0x80,
                    0x1C,
                    0x75,
                    0x3F,
                    0x00,
                    0x21,
                    0x72,
                    0x52,
                    0x00,
                    0x24,
                    0x72,
                    0x40,
                    0x00,
                    0x29,
                    0x71,
                    0x53,
                    0x00,
                    0x2C,
                    0x50,
                    0x42,
                    0x00,
                    0x31,
                    0x51,
                    0x55,
                    0x00,
                    0x34,
                    0x50,
                    0x42,
                    0x00
                ]))
                let lastPulseNumber = Int(podInfoPulseLogRecent.indexLastEntry)
                return pulseLogString(pulseLogEntries: podInfoPulseLogRecent.pulseLog, lastPulseNumber: lastPulseNumber)
            }
        }
    }
}
