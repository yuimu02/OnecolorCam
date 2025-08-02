//
//  Trigger.swift
//  OnecolorCam
//
//  Created by Yuiko Muroyama on 2025/07/30.
//

import SwiftUI

public struct Trigger: Equatable {

    private var value: String = ""

    public init() {}

    public static func == (lhs: Trigger, rhs: Trigger) -> Bool {
        lhs.value == rhs.value
    }

    public mutating func fire() {
        var newUUID = UUID().uuidString
        while value == newUUID {
            newUUID = UUID().uuidString
        }
        self.value = newUUID
    }
}
