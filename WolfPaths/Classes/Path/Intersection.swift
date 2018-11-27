//
//  Intersection.swift
//  WolfPaths
//
//  Created by Wolf McNally on 11/13/18.
//

import WolfGeometry
import WolfNumerics

public struct Intersection: Equatable, Comparable {
    public let t1: Double
    public let t2: Double
    public static func < (lhs: Intersection, rhs: Intersection) -> Bool {
        if lhs.t1 < rhs.t1 {
            return true
        } else if lhs.t1 == rhs.t1 {
            return lhs.t2 < rhs.t2
        } else {
            return false
        }
    }
}
