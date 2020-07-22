//
//  NSScreen+Extension.swift
//  QuickDraw
//
//  Created by Max Chuquimia on 3/4/19.
//  Copyright © 2019 Max Chuquimia. All rights reserved.
//

import Cocoa

// https://gist.github.com/salexkidd/bcbea2372e92c6e5b04cbd7f48d9b204
extension NSScreen {

    public var displayID: CGDirectDisplayID {
        get {
            return deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as! CGDirectDisplayID
        }
    }

    public var displayName: String? {
        get {
            var name: String?
            var object : io_object_t
            var serialPortIterator = io_iterator_t()
            let matching = IOServiceMatching("IODisplayConnect")

            let kernResult = IOServiceGetMatchingServices(kIOMasterPortDefault, matching, &serialPortIterator)
            if KERN_SUCCESS == kernResult && serialPortIterator != 0 {
                repeat {
                    object = IOIteratorNext(serialPortIterator)
                    let displayInfo = IODisplayCreateInfoDictionary(object, UInt32(kIODisplayOnlyPreferredName)).takeRetainedValue() as NSDictionary as! [String:AnyObject]

                    if  (displayInfo[kDisplayVendorID] as? UInt32 == CGDisplayVendorNumber(displayID) &&
                        displayInfo[kDisplayProductID] as? UInt32 == CGDisplayModelNumber(displayID) &&
                        displayInfo[kDisplaySerialNumber] as? UInt32 ?? 0 == CGDisplaySerialNumber(displayID)
                        ) {
                        if let productName = displayInfo["DisplayProductName"] as? [String:String],
                            let firstKey = Array(productName.keys).first {
                            name = productName[firstKey]!
                            break
                        }
                    }
                } while object != 0
            }
            IOObjectRelease(serialPortIterator)
            return name
        }
    }

    var dockHeight: CGFloat {
        visibleFrame.origin.y - frame.origin.y
    }

}
