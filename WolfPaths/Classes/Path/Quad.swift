//
//  Quad.swift
//  WolfPaths
//
//  Created by Wolf McNally on 11/11/18.
//

import WolfGeometry
import WolfNumerics
import WolfPipe

public struct Quad: Curve {
    public var p0, p1, p2: Point

    public init(p0: Point, p1: Point, p2: Point) {
        self.p0 = p0
        self.p1 = p1
        self.p2 = p2
    }

    public init(points: [Point]) {
        precondition(points.count == 3)
        self.p0 = points[0]
        self.p1 = points[1]
        self.p2 = points[2]
    }

    public init(line l: Line) {
        self.init(p0: l.p0, p1: l.p0.interpolated(to: l.p1, at: 0.5), p2: l.p1)
    }

    public init(from: Point, to: Point, mid: Point, t: Frac = 0.5) {
        // shortcuts, although they're really dumb
        if t == 0 {
            self.init(p0: mid, p1: mid, p2: to)
        } else if t == 1 {
            self.init(p0: from, p1: mid, p2: mid)
        } else {
            // real fitting.
            let abc = Utils.getABC(n: 2, S: from, B: mid, E: to, t: t)
            self.init(p0: from, p1: abc.A, p2: to)
        }
    }

    public var from: Point { return p0 }
    public var to: Point { return p2 }
    public var order: Int { return 2 }
    public var points: [Point] { return [p0, p1, p2] }
    public var segment: Segment { return .quad(p1: p1, p2: p2) }

    public var isSimple: Bool {
        let n1 = normal(at: 0)
        let n2 = normal(at: 1)
        let s = dot(n1, n2).clamped(to: -1 ... 1)
        let angle = s |> acos |> abs
        return angle < .pi / 3.0
    }

    public func point(at t: Frac) -> Point {
        guard t > 0 else { return p0 }
        guard t < 1 else { return p2 }
        let mt = 1 - t
        let mt2 = mt * mt
        let t2 = t * t
        let a = mt2
        let b = mt * t * 2
        let c = t2
        return p0 * a + p1 * b + p2 * c
    }

    public func vector(at t: Frac) -> Vector {
        let v0 = (p1 - p0) * 2
        let v1 = (p2 - p1) * 2
        let mt = 1 - t
        let a = mt
        let b = t
        return v0 * a + v1 * b
    }

//    public var length: Double {
//        // Adapted from https://gist.github.com/tunght13488/6744e77c242cc7a94859#gistcomment-2047251
//        let ax = p0.x - 2 * p1.x + p2.x
//        let ay = p0.y - 2 * p1.y + p2.y
//        let bx = 2 * p1.x - 2 * p0.x
//        let by = 2 * p1.y - 2 * p0.y
//        let A = 4 * (ax * ax + ay * ay)
//        let B = 4 * (ax * bx + ay * by)
//        let C = bx * bx + by * by
//
//        let Sabc = 2 * sqrt(A+B+C)
//        let A_2 = sqrt(A)
//        let A_32 = 2 * A * A_2
//        let C_2 = 2 * sqrt(C)
//        let BA = B / A_2
//
//        return (A_32 * Sabc + A_2 * B * (Sabc - C_2) + (4 * C * A - B * B) * log((2 * A_2 + BA + Sabc) / (BA + C_2))) / (4 * A_32)
//    }

    public func split(from t1: Double, to t2: Double) -> Quad {
        let h0 = self.p0
        let h1 = self.p1
        let h2 = self.p2
        let h3 = h0.interpolated(to: h1, at: t1)
        let h4 = h1.interpolated(to: h2, at: t1)
        let h5 = h3.interpolated(to: h4, at: t1)

        let tr = t2.lerpedToFrac(from: t1 .. 1)

        let i0 = h5
        let i1 = h4
        let i2 = h2
        let i3 = i0.interpolated(to: i1, at: tr)
        let i4 = i1.interpolated(to: i2, at: tr)
        let i5 = i3.interpolated(to: i4, at: tr)

        return Quad(p0: i0, p1: i3, p2: i5)
    }

    public func split(at t: Double) -> (left: Quad, right: Quad) {
        // use "de Casteljau" iteration.
        let h0 = self.p0
        let h1 = self.p1
        let h2 = self.p2
        let h3 = h0.interpolated(to: h1, at: t)
        let h4 = h1.interpolated(to: h2, at: t)
        let h5 = h3.interpolated(to: h4, at: t)

        let leftCurve = Quad(p0: h0, p1: h3, p2: h5)
        let rightCurve = Quad(p0: h5, p1: h4, p2: h2)

        return (left: leftCurve, right: rightCurve)
    }

    public var boundingBox: BoundingBox {
        var mmin = Point.min(p0, p2)
        var mmax = Point.max(p0, p2)

        let d0 = p1 - p0
        let d1 = p2 - p1

        for d in 0 ..< Point.dimensions {
            Utils.droots(d0[d], d1[d]) { t in
                guard t > 0, t < 1 else { return }

                let value = self.point(at: t)[d]

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

extension Quad: Equatable {
    public static func == (lhs: Quad, rhs: Quad) -> Bool {
        return lhs.p0 == rhs.p0 && lhs.p1 == rhs.p1 && lhs.p2 == rhs.p2
    }
}

extension Quad: Transformable {
    public func transformed(using t: Transform) -> Quad {
        return Quad(p0: p0.applying(t), p1: p1.applying(t), p2: p2.applying(t))
    }
}

extension Quad: Reversible {
    public func reversed() -> Quad {
//    public var reversed: Quad {
        return Quad(p0: p2, p1: p1, p2: p0)
    }
}
