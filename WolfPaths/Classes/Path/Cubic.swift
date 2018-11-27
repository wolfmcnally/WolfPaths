//
//  Cubic.swift
//  WolfPaths
//
//  Created by Wolf McNally on 11/11/18.
//

import WolfGeometry
import WolfNumerics
import WolfPipe

public struct Cubic: Curve {
    public let p0: Point
    public let p1: Point
    public let p2: Point
    public let p3: Point

    public init(p0: Point, p1: Point, p2: Point, p3: Point) {
        self.p0 = p0
        self.p1 = p1
        self.p2 = p2
        self.p3 = p3
    }

    public init(points: [Point]) {
        precondition(points.count == 4)
        self.p0 = points[0]
        self.p1 = points[1]
        self.p2 = points[2]
        self.p3 = points[3]
    }

    public init(line l: Line) {
        let oneThird = 1.0 / 3.0
        let twoThirds = 2.0 / 3.0
        self.init(p0: l.p0, p1: l.p0 * twoThirds + l.p1 * oneThird, p2: l.p0 * oneThird + l.p1 * twoThirds, p3: l.p1)
    }

    public init(quad q: Quad) {
        let oneThird = 1.0 / 3.0
        let twoThirds = 2.0 / 3.0
        let p0 = q.p0
        let p1 = q.p1 * twoThirds + q.p0 * oneThird
        let p2 = q.p2 * oneThird + q.p1 * twoThirds
        let p3 = q.p2
        self.init(p0: p0, p1: p1, p2: p2, p3: p3)
    }

    ///     Returns a CubicBezierCurve which passes through three provided points: a starting point `start`, and ending point `end`, and an intermediate point `mid` at an optional t-value `t`.
    ///
    ///     - parameter start: the starting point of the curve
    ///     - parameter end: the ending point of the curve
    ///     - parameter mid: an intermediate point falling on the curve
    ///     - parameter t: optional t-value at which the curve will pass through the point `mid` (default = 0.5)
    ///     - parameter d: optional strut length with the full strut being length d * (1-t)/t. If omitted or `nil` the distance from `mid` to the baseline (line from `start` to `end`) is used.
    public init(from: Point, to: Point, mid: Point, t: Double = 0.5, d: Double? = nil) {
        let s = from
        let b = mid
        let e = to

        let abc = Utils.getABC(n: 3, S: s, B: b, E: e, t: t)

        let d1 = (d != nil) ? d! : (abc.C - b).magnitude
        let d2 = d1 * (1.0 - t) / t

        let selen = (to - from).magnitude
        let lx = (e.x - s.x) / selen
        let ly = (e.y - s.y) / selen
        let bx1 = d1 * lx
        let by1 = d1 * ly
        let bx2 = d2 * lx
        let by2 = d2 * ly

        // derivation of new hull coordinates
        let e1  = Point( x: b.x - bx1, y: b.y - by1 )
        let e2  = Point( x: b.x + bx2, y: b.y + by2 )
        let A   = abc.A
        let oneMinusT = 1.0 - t
        let v1  = A + (e1-A) / oneMinusT
        let v2  = A + (e2-A) / t
        let nc1 = s + (v1-s) / t
        let nc2 = e + (v2-e) / oneMinusT
        // ...done
        self.init(p0:s, p1: nc1, p2: nc2, p3: e)
    }

    public var from: Point { return p0 }
    public var to: Point { return p3 }
    public var order: Int { return 3 }
    public var points: [Point] { return [p0, p1, p2, p3]  }
    public var segment: Segment { return .cubic(p1: p1, p2: p2, p3: p3) }

    public var isSimple: Bool {
        let a1 = angleAtVertex(o: p0, p3, p1)
        let a2 = angleAtVertex(o: p0, p3, p2)
        if a1 > 0 && a2 < 0 || a1 < 0 && a2 > 0 {
            return false
        }
        let n1 = normal(at: 0)
        let n2 = normal(at: 1)
        let s = dot(n1, n2).clamped(to: -1 ... 1)
        let angle = s |> acos |> abs
        return angle < .pi / 3.0
    }

    public func point(at t: Frac) -> Point {
        guard t > 0 else { return p0 }
        guard t < 1 else { return p3 }
        let mt = 1 - t
        let mt2 = mt * mt
        let t2 = t * t
        let a = mt2 * mt
        let b = mt2 * t * 3
        let c = mt * t2 * 3
        let d = t * t2
        return p0 * a + p1 * b + p2 * c + p3 * d
    }

    public func vector(at t: Frac) -> Vector {
        let k = 3.0
        let v0 = (p1 - p0) * k
        let v1 = (p2 - p1) * k
        let v2 = (p3 - p2) * k
        let mt = 1 - t
        let a = mt * mt
        let b = mt * t * 2
        let c = t * t
        return v0 * a + v1 * b + v2 * c
    }

    public func split(from t1: Double, to t2: Double) -> Cubic {
        let h0 = self.p0
        let h1 = self.p1
        let h2 = self.p2
        let h3 = self.p3
        let h4 = h0.interpolated(to: h1, at: t1)
        let h5 = h1.interpolated(to: h2, at: t1)
        let h6 = h2.interpolated(to: h3, at: t1)
        let h7 = h4.interpolated(to: h5, at: t1)
        let h8 = h5.interpolated(to: h6, at: t1)
        let h9 = h7.interpolated(to: h8, at: t1)

        let tr = t2.lerpedToFrac(from: t1 .. 1)

        let i0 = h9
        let i1 = h8
        let i2 = h6
        let i3 = h3
        let i4 = i0.interpolated(to: i1, at: tr)
        let i5 = i1.interpolated(to: i2, at: tr)
        let i6 = i2.interpolated(to: i3, at: tr)
        let i7 = i4.interpolated(to: i5, at: tr)
        let i8 = i5.interpolated(to: i6, at: tr)
        let i9 = i7.interpolated(to: i8, at: tr)

        return Cubic(p0: i0, p1: i4, p2: i7, p3: i9)
    }

    public func split(at t: Double) -> (left: Cubic, right: Cubic) {
        let h0 = self.p0
        let h1 = self.p1
        let h2 = self.p2
        let h3 = self.p3
        let h4 = h0.interpolated(to: h1, at: t)
        let h5 = h1.interpolated(to: h2, at: t)
        let h6 = h2.interpolated(to: h3, at: t)
        let h7 = h4.interpolated(to: h5, at: t)
        let h8 = h5.interpolated(to: h6, at: t)
        let h9 = h7.interpolated(to: h8, at: t)

        let leftCurve  = Cubic(p0: h0, p1: h4, p2: h7, p3: h9)
        let rightCurve = Cubic(p0: h9, p1: h8, p2: h6, p3: h3)

        return (left: leftCurve, right: rightCurve)
    }

    public var boundingBox: BoundingBox {
        var mmin = Point.min(p0, p3)
        var mmax = Point.max(p0, p3)

        let d0 = p1 - p0
        let d1 = p2 - p1
        let d2 = p3 - p2

        for d in 0 ..< Point.dimensions {
            Utils.droots(d0[d], d1[d], d2[d]) { r in
                guard r > 0, r < 1 else { return }

                let value = self.point(at: r)[d]

                if value < mmin[d] {
                    mmin[d] = value
                } else if value > mmax[d] {
                    mmax[d] = value
                }
            }
        }
        return BoundingBox(min: mmin, max: mmax)
    }
}

extension Cubic: Equatable {
    public static func == (lhs: Cubic, rhs: Cubic) -> Bool {
        return lhs.p0 == rhs.p0 && lhs.p1 == rhs.p1 && lhs.p2 == rhs.p2 && lhs.p3 == rhs.p3
    }
}

extension Cubic: Transformable {
    public func transformed(using t: Transform) -> Cubic {
        return Cubic(p0: p0.applying(t), p1: p1.applying(t), p2: p2.applying(t), p3: p3.applying(t))
    }
}

extension Cubic: Reversible {
    public func reversed() -> Cubic {
//    public var reversed: Cubic {
        return Cubic(p0: p3, p1: p2, p2: p1, p3: p0)
    }
}
