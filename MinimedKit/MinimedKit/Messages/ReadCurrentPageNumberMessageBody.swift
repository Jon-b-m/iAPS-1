import Foundation

public class ReadCurrentPageNumberMessageBody: CarelinkLongMessageBody {
    public let pageNum: Int

    // Partially implemented from https://github.com/bewest/decoding-carelink/blob/master/decocare/commands.py#L575
    public required init?(rxData: Data) {
        var page = 0

        // NOTE: Page Number  is likely 4 bytes little endian but anything longer that one byte is not implemented
        if rxData.count > 1 {
            page = Int(rxData[0])
        }

        if page < 0 || page > 36 {
            page = 36
        }

        pageNum = page
        super.init(rxData: rxData)
    }
}
