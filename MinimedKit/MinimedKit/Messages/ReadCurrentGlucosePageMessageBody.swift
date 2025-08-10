import Foundation

public class ReadCurrentGlucosePageMessageBody: CarelinkLongMessageBody {
    public let pageNum: UInt32
    public let glucose: Int
    public let isig: Int

    public required init?(rxData: Data) {
        guard rxData.count == type(of: self).length else {
            return nil
        }

        pageNum = rxData[
            1 ..< 5
        ].toBigEndian(UInt32.self)
        glucose = Int(rxData[6])
        isig = Int(rxData[8])

        super.init(rxData: rxData)
    }
}
