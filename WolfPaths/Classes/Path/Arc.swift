//
//  Arc.swift
//  WolfPaths
//
//  Created by Wolf McNally on 11/13/18.
//

import WolfGeometry
import WolfNumerics

public struct Arc: Equatable {
    public var origin: Point
    public var radius: Double
    public var startAngle, endAngle: Double // radians
    public var interval: Interval<Double> // represents t-values [0, 1] on curve

    public init(origin: Point, radius: Double, startAngle: Double, endAngle: Double, interval: Interval<Double> = .unit) {
        self.origin = origin
        self.radius = radius
        self.startAngle = startAngle
        self.endAngle = endAngle
        self.interval = interval
    }

    public func compute(_ t: Double) -> Point {
        // computes a value on the arc with t in [0, 1]
        let theta: Double = t * self.endAngle + (1.0 - t) * self.startAngle
        return origin + Vector(dx: cos(theta), dy: sin(theta)) * radius
    }
}
