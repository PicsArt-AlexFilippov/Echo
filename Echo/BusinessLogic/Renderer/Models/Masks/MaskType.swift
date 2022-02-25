//
//  MaskType.swift
//  Echo
//
//  Created by Филиппов Алексей on 25.02.2022.
//

import UIKit

enum MaskType: Int {
    case shape
    case brush
    case text
    
    func maskTypeId() -> Int {
        return rawValue
    }
}
