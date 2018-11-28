//
//  Line.swift
//  WolfPaths
//
//  Created by Wolf McNally on 11/11/18.
//

import WolfGeometry
import WolfNumerics

public struct Line: Curve {
    public var p0, p1: Point

    public init(p0: Point, p1: Point) {
        self.p0 = p0
        self.p1 = p1
    }
    
    public init(points: [Point]) {
        precondition(points.count == 2)
        self.p0 = points[0]
        self.p1 = points[1]
    }

    public var from: Point { return p0 }
    public var to: Point { return p1 }
    public var order: Int { return 1 }
    public var points: [Point] { return [p0, p1] }
    public var segment: Segment { return .line(p1: p1) }
    public var isSimple: Bool { return true }

    public func point(at t: Frac) -> Point {
        guard t > 0 else { return p0 }
        guard t < 1 else { return p1 }
        return p0.interpolated(to: p1, at: t)
    }

    public func vector(at t: Frac) -> Vector {
        return p1 - p0
    }

    public func split(from t1: Double, to t2: Double) -> Line {
        let p0 = self.p0
        let p1 = self.p1
        return Line(p0: p0.interpolated(to: p1, at: t1),
                    p1: p0.interpolated(to: p1, at: t2))
    }

    public func split(at t: Double) -> (left: Line, right: Line) {
        let p0  = self.p0
        let p1  = self.p1
        let mid = p0.interpolated(to: p1, at: t)
        let left = Line(p0: p0, p1: mid)
        let right = Line(p0: mid, p1: p1)
        return (left: left, right: right)
    }

    public var boundingBox: BoundingBox {
        return BoundingBox(min: Point.min(p0, p1), max: Point.max(p0, p1))
    }
}

extension Line: Equatable {
    public static func == (lhs: Line, rhs: Line) -> Bool {
        return lhs.p0 == rhs.p0 && lhs.p1 == rhs.p1
    }
}

extension Line {
    public var length: Double {
        return (p1 - p0).magnitude
    }
}

extension Line {
    public var extrema: (xyz: [[Double]], values: [Double]) {
        // for a line segment the extrema are trivially just the start and end points
        // which have t = 0.0 and 1.0
        var xyz: [[Double]] = []
        for _ in 0 ..< Point.dimensions {
            xyz.append([0.0, 1.0])
        }
        return (xyz: xyz, [0.0, 1.0])
    }

    public func intersects(curve: Curve, threshold: Double = defaultIntersectionThreshold) -> [Intersection] {
        if let l = curve as? Line {
            // use fast line / line intersection algorithm
            return self.intersects(line: l)
        }
        // call into the curve's line intersection algorithm
        let intersections = curve.intersects(line: self)
        // invert and re-sort the order of the intersections since
        // intersects was called on the line and not the curve
        return intersections.map({(i: Intersection) in
            return Intersection(t1: i.t2, t2: i.t1)
        }).sorted()
    }

    public func intersects(line: Line) -> [Intersection] {
        let a1 = p0
        let b1 = p1 - p0
        let a2 = line.p0
        let b2 = line.p1 - line.p0

        let _a = b1.dx
        let _b = -b2.dx
        let _c = b1.dy
        let _d = -b2.dy

        // by Cramer's rule we have
        // t1 = ed - bf / ad - bc
        // t2 = af - ec / ad - bc
        let det = _a * _d - _b * _c
        let inv_det = 1.0 / det

        if inv_det.isFinite == false {
            // lines are effectively parallel. Multiplying by inv_det will yield Inf or NaN, neither of which is valid
            return []
        }

        let _e = -a1.x + a2.x
        let _f = -a1.y + a2.y

        var t1 = ( _e * _d - _b * _f ) * inv_det // if inv_det is inf then this is NaN!
        var t2 = ( _a * _f - _e * _c ) * inv_det // if inv_det is inf then this is NaN!

        if t1 ≈ (0.0, Utils.epsilon) {
            t1 = 0.0
        } else if t1 ≈ (1.0, Utils.epsilon) {
            t1 = 1.0
        }
        if t2 ≈ (0.0, Utils.epsilon) {
            t2 = 0.0
        } else if t2 ≈ (1.0, Utils.epsilon) {
            t2 = 1.0
        }

        if t1 > 1.0 || t1 < 0.0  {
            return [] // t1 out of interval [0, 1]
        }
        if t2 > 1.0 || t2 < 0.0 {
            return [] // t2 out of interval [0, 1]
        }
        return [Intersection(t1: t1, t2: t2)]
    }
}

extension Line {
    public func transformed(using t: Transform) -> Line {
        return Line(p0: p0.applying(t), p1: p1.applying(t))
    }
}

extension Line {
    public func reversed() -> Line {
        return Line(p0: p1, p1: p0)
    }
//    public var reversed: Line {
//        return Line(p0: p1, p1: p0)
//    }
}
