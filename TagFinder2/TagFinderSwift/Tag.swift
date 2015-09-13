//
//  Tag.swift
//  TagFinderSwift
//
//  Created by Fabiola Ramirez on 9/10/15.
//  Copyright (c) 2015 Fabiola Ramirez. All rights reserved.
//

import UIKit

class Tag: NSObject {
   
    var epc :String = ""
    var crc : NSNumber = 0
    var pc : NSNumber = 0
    var rssi : NSNumber = 0
    var fastId : NSData?
    var count:Int = 0
    var bit: Int = 0
    
    
    override init () {
        
        epc = ""
        crc = 0
        pc = 0
        rssi = 0
        fastId = NSData()
        count = 0
        bit = 0
    }
    
    
    
    
}
