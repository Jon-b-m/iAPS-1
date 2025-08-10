import Foundation

public class SelectBasalProfileMessageBody: CarelinkLongMessageBody {
    public convenience init(newProfile: BasalProfile) {
        self.init(rxData: Data([1, newProfile.rawValue]))!
    }
}
