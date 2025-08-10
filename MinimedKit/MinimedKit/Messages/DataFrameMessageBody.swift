import Foundation

public class DataFrameMessageBody: CarelinkLongMessageBody {
    public let isLastFrame: Bool
    public let frameNumber: Int
    public let contents: Data

    public required init?(rxData: Data) {
        guard rxData.count == type(of: self).length else {
            return nil
        }

        isLastFrame = rxData[0] & 0b1000_0000 != 0
        frameNumber = Int(rxData[0] & 0b0111_1111)
        contents = rxData.subdata(in: 1 ..< rxData.count)

        super.init(rxData: rxData)
    }

    init(frameNumber: Int, isLastFrame: Bool, contents: Data) {
        self.frameNumber = frameNumber
        self.isLastFrame = isLastFrame
        self.contents = contents

        super.init(rxData: Data())!
    }

    override public var txData: Data {
        var byte0 = UInt8(frameNumber)
        if isLastFrame {
            byte0 |= 0b1000_0000
        }

        var data = Data([byte0])
        data.append(contents)

        return data
    }
}

public extension DataFrameMessageBody {
    static func dataFramesFromContents(_ contents: Data) -> [DataFrameMessageBody] {
        var frames = [DataFrameMessageBody]()
        let frameContentsSize = DataFrameMessageBody.length - 1

        for frameNumber in sequence(first: 0, next: { $0 + 1 }) {
            let startIndex = frameNumber * frameContentsSize
            var endIndex = startIndex + frameContentsSize
            var isLastFrame = false

            if endIndex >= contents.count {
                isLastFrame = true
                endIndex = contents.count
            }

            frames.append(DataFrameMessageBody(
                frameNumber: frameNumber + 1,
                isLastFrame: isLastFrame,
                contents: contents[startIndex ..< endIndex]
            ))

            if isLastFrame {
                break
            }
        }

        return frames
    }
}
