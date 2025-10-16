//
//  TodaysColor.swift
//  OnecolorCam
//
//  Created by Yuiko Muroyama on 2025/08/27.  made with chappy
//

import Foundation
import SwiftUI

@inline(__always)
private func fnv1a64(_ bytes: [UInt8]) -> UInt64 {
    var h: UInt64 = 0xcbf29ce484222325
    let p: UInt64 = 0x100000001b3
    for b in bytes { h ^= UInt64(b); h &*= p }
    return h
}

@inline(__always)
private func splitmix64(_ x: UInt64) -> UInt64 {
    var z = x &+ 0x9e3779b97f4a7c15
    z = (z ^ (z >> 30)) &* 0xbf58476d1ce4e5b9
    z = (z ^ (z >> 27)) &* 0x94d049bb133111eb
    return z ^ (z >> 31)
}

private func fract(_ x: Double) -> Double { x - floor(x) }

/// 同じ(uid, date)で固定，翌日/別ユーザーで変化
func calculateColor(for date: Date, uid: String,
                    timeZone: TimeZone = TimeZone(identifier: "Asia/Tokyo")!) -> Color {

    var cal = Calendar(identifier: .gregorian)
    cal.timeZone = timeZone
    let dayStart = cal.startOfDay(for: date) // 日付境界をTZに合わせる
    let dayNumber = Int(dayStart.timeIntervalSinceReferenceDate / 86_400.0)

    let uidHash = fnv1a64(Array(uid.utf8))
    let uidOffset = Double(uidHash & 0xFFFFFF) / Double(0x1_000000) // 0..1

    let golden = 0.6180339887498949
    let hue = fract(Double(dayNumber) * golden + uidOffset)

    let seed = splitmix64(uidHash ^ UInt64(bitPattern: Int64(dayNumber)))
    let r1 = Double(splitmix64(seed &+ 0x1234_5678_9ABC_DEF0)) / Double(UInt64.max)
    let r2 = Double(splitmix64(seed &+ 0x0FED_CBA9_8765_4321)) / Double(UInt64.max)

    let sat = 0.60 + 0.35 * r1
    let bri = 0.70 + 0.25 * r2 

    return Color(hue: hue, saturation: sat, brightness: bri)
}

func colorForToday(date: Date, uid: String,
                   timeZone: TimeZone = TimeZone(identifier: "Asia/Tokyo")!) -> Color {
    calculateColor(for: date, uid: uid, timeZone: timeZone)
}
