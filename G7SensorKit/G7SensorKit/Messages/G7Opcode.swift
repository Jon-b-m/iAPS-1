import Foundation

enum G7Opcode: UInt8 {
    case authChallengeRx = 0x05
    case sessionStopTx = 0x28
    case glucoseTx = 0x4E
    case backfillFinished = 0x59
}
