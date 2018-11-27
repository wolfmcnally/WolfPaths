//
//  TestHelpers.swift
//  WolfPaths_Tests
//
//  Created by Wolf McNally on 11/18/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import WolfPaths
import WolfGeometry
import WolfNumerics

class TestHelpers {

    static internal func intersections(_ intersections: [Intersection], betweenCurve c1: Curve, andOtherCurve c2: Curve, areWithinTolerance epsilon: Double) -> Bool {
        for i in intersections {
            let p1 = c1.point(at: i.t1)
            let p2 = c2.point(at: i.t2)
            if (p1 - p2).magnitude > epsilon {
                return false
            }
        }
        return true
    }

    static internal func curveControlPointsEqual(curve1 c1: Curve, curve2 c2: Curve, tolerance epsilon: Double) -> Bool {
        if c1.order != c2.order {
            return false
        }
        for i in 0...c1.order {
            if (c1.points[i] - c2.points[i]).magnitude > epsilon {
                return false
            }
        }
        return true
    }

//    static internal func shape(_ s: Shape, matchesShape other: Shape, tolerance: Double = 1.0e-6) -> Bool {
//        guard curve(s.forward, matchesCurve: other.forward, tolerance: tolerance) else {
//            return false
//        }
//        guard curve(s.back, matchesCurve: other.back, tolerance: tolerance) else {
//            return false
//        }
//        guard curve(s.startcap.curve, matchesCurve: other.startcap.curve, tolerance: tolerance) else {
//            return false
//        }
//        guard curve(s.endcap.curve, matchesCurve: other.endcap.curve, tolerance: tolerance) else {
//            return false
//        }
//        guard s.startcap.virtual == other.startcap.virtual else {
//            return false
//        }
//        guard s.endcap.virtual == other.endcap.virtual else {
//            return false
//        }
//        return true
//    }

    static internal func curve(_ c1: Curve, matchesCurve c2: Curve, overInterval interval: Interval<Double> = 0.0 .. 1.0, tolerance: Double = 1.0e-5) -> Bool {
        // checks if c1 over [0, 1] matches c2 over [interval.start, interval.end]
        // useful for checking if splitting a curve over a given interval worked correctly
        let numPointsToCheck = 10
        for i in 0..<numPointsToCheck {
            let t1 = Double(i) / Double(numPointsToCheck-1)
            let t2 = interval.a * (1.0 - t1) + interval.b * t1
            if (c1.point(at: t1) - c2.point(at: t2)).magnitude > tolerance {
                return false
            }
        }
        return true
    }

    private static func evaluatePolynomial(_ p: [Double], at t: Double) -> Double {
        var sum: Double = 0.0
        for n in 0..<p.count {
            sum += p[p.count - n - 1] * pow(t, Double(n))
        }
        return sum
    }

    static func cubicBezierCurveFromPolynomials(_ f: [Double], _ g: [Double]) -> Cubic {
        precondition(f.count == 4 && g.count == 4)
        // create a cubic bezier curve from two polynomials
        // the first polynomial f[0] t^3 + f[1] t^2 + f[2] t + f[3] defines x(t) for the Bezier curve
        // the second polynomial g[0] t^3 + g[1] t^2 + g[2] t + g[3] defines y(t) for the Bezier curve
        let p = Vector(dx: f[0], dy: g[0])
        let q = Vector(dx: f[1], dy: g[1])
        let r = Vector(dx: f[2], dy: g[2])
        let s = Vector(dx: f[3], dy: g[3])
        let a = s
        let b = r / 3 + a
        let c = q / 3 + b * 2 - a
        let d = p + a - b * 3 + c * 3
        // check that it worked
        let curve = Cubic(p0: Point(a), p1: Point(b), p2: Point(c), p3: Point(d))
        for t: Double in stride(from: 0, through: 1, by: 0.1) {
            assert((curve.point(at: t) - Point(x: evaluatePolynomial(f, at: t), y: evaluatePolynomial(g, at: t))).magnitude < 0.001, "internal error! failed to fit polynomial!")
        }
        return curve
    }

    //    static func quadraticBezierCurveFromPolynomials(_ f: [Double], _ g: [Double]) -> QuadraticBezierCurve {
    //        precondition(f.count == 3 && g.count == 3)
    //        // create a quadratic bezier curve from two polynomials
    //        // the first polynomial f[0] t^2 + f[1] t + f[2] defines x(t) for the Bezier curve
    //        // the second polynomial g[0] t^2 + g[1] t + g[2] defines y(t) for the Bezier curve
    //        let q = Point(x: f[0], y: g[0])
    //        let r = Point(x: f[1], y: g[1])
    //        let s = Point(x: f[2], y: g[2])
    //        let a = s
    //        let b = r / 3.0 + a
    //        let c = q / 3.0 + 2.0 * b - a
    //        // check that it worked
    //        let curve = QuadraticBezierCurve(p0: a, p1: b, p2: c)
    //        for t: Double in stride(from: 0, through: 1, by: 0.1) {
    //            assert(distance(curve.point(at: t), Point(x: evaluatePolynomial(f, at: t), y: evaluatePolynomial(g, at: t))) < 0.001, "internal error! failed to fit polynomial!")
    //        }
    //        return curve
    //    }

}
