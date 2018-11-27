//
//  BoundingBox.swift
//  WolfPaths
//
//  Created by Wolf McNally on 11/11/18.
//

import WolfGeometry
import WolfNumerics

public struct BoundingBox: Equatable {
    public let min: Point
    public let max: Point

    public var rect: Rect {
        return Rect(origin: min, size: size)
    }

    public static let empty: BoundingBox = BoundingBox(min: .infinite, max: -.infinite)
    
    public init(min: Point, max: Point) {
        self.min = min
        self.max = max
    }

    public func union(_ other: BoundingBox) -> BoundingBox {
        return BoundingBox(min: Point.min(min, other.min), max: Point.max(max, other.max))
    }

    public init(p1: Point, p2: Point) {
        min = Point.min(p1, p2)
        max = Point.max(p1, p2)
    }

    public init(first: BoundingBox, second: BoundingBox) {
        min = Point.min(first.min, second.min)
        max = Point.max(first.max, second.max)
    }

    public var size: Size {
        return Size(Vector.max(max - min, .zero))
    }

    var area: Double {
        let size = self.size
        return size.width * size.height
    }

    public func overlaps(_ other: BoundingBox) -> Bool {
        let p1 = Point.max(min, other.min)
        let p2 = Point.min(max, other.max)
        for i in 0 ..< Point.dimensions {
            let difference = p2[i] - p1[i]
            if difference.isNaN || difference < 0 {
                return false
            }
        }
        return true
    }

    func lowerBoundOfDistance(to point: Point) -> Double {
        let distanceSquared = (0..<Point.dimensions).reduce(Double(0.0)) {
            let temp = point[$1] - point[$1].clamped(to: min[$1] ... max[$1])
            return $0 + temp * temp
        }
        return sqrt(distanceSquared)
    }

    func upperBoundOfDistance(to point: Point) -> Double {
        let distanceSquared = (0..<Point.dimensions).reduce(Double(0.0)) {
            let diff1 = point[$1] - min[$1]
            let diff2 = point[$1] - max[$1]
            return $0 + Double.maximum(diff1 * diff1, diff2 * diff2)
        }
        return sqrt(distanceSquared)
    }
}
