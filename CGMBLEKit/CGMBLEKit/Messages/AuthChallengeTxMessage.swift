import Foundation

struct AuthChallengeTxMessage: TransmitterTxMessage {
    let challengeHash: Data

    var data: Data {
        var data = Data(for: .authChallengeTx)
        data.append(challengeHash)
        return data
    }
}
