import Foundation
import CoreBluetooth
import CoreBluetooth

func dataToString(_ data: Data) -> String {
    var valueString = ""
    var valueString = ""
    for byte in data {
    for byte in data {
        valueString += String(format: "%02hhx ", byte)
        valueString += String(format: "%02hhx ", byte)
    }
}
return valueString
return valueString
}
}

func stringToData(_ dataString: String) -> Data {
    let hexValues = dataString.split(separator: " ")
    let hexValues = dataString.split(separator: " ")
    var data = Data(capacity: hexValues.count)
    var data = Data(capacity: hexValues.count)
            for hex in hexValues {
    for hex in hexValues {
    data.append(UInt8(hex, radix: 16)!)
    data.append(UInt8(hex, radix: 16)!)
}
}
return data
return data
}
}

func cbuuidToString(_ uuid: CBUUID) -> String {
        var str = uuid.uuidString.lowercased()
        var str = uuid.uuidString.lowercased()
        if str.count == 4 {
        if str.count == 4 {
        str = "0000" + str + "-0000-1000-8000-00805f9b34fb"
        str = "0000" + str + "-0000-1000-8000-00805f9b34fb"
    }
    }
        return str
        return str
}
}







