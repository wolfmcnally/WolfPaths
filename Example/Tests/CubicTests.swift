//
//  CubicTests.swift
//  WolfPaths_Tests
//
//  Created by Wolf McNally on 11/18/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
import WolfPaths
import WolfGeometry
import WolfNumerics

class CubicTests: XCTestCase {
    func testInitializerArray() {
        let c = Cubic(points: [Point(x: 1.0, y: 1.0), Point(x: 3.0, y: 2.0), Point(x: 5.0, y: 3.0), Point(x: 7.0, y: 4.0)])
        XCTAssertEqual(c.p0, Point(x: 1.0, y: 1.0))
        XCTAssertEqual(c.p1, Point(x: 3.0, y: 2.0))
        XCTAssertEqual(c.p2, Point(x: 5.0, y: 3.0))
        XCTAssertEqual(c.p3, Point(x: 7.0, y: 4.0))
        XCTAssertEqual(c.from, Point(x: 1.0, y: 1.0))
        XCTAssertEqual(c.to, Point(x: 7.0, y: 4.0))
    }

    func testInitializerIndividualPoints() {
        let c = Cubic(p0: Point(x: 1.0, y: 1.0), p1: Point(x: 3.0, y: 2.0), p2: Point(x: 5.0, y: 3.0), p3: Point(x: 7.0, y: 4.0))
        XCTAssertEqual(c.p0, Point(x: 1.0, y: 1.0))
        XCTAssertEqual(c.p1, Point(x: 3.0, y: 2.0))
        XCTAssertEqual(c.p2, Point(x: 5.0, y: 3.0))
        XCTAssertEqual(c.p3, Point(x: 7.0, y: 4.0))
        XCTAssertEqual(c.from, Point(x: 1.0, y: 1.0))
        XCTAssertEqual(c.to, Point(x: 7.0, y: 4.0))
    }

    func testInitializerLineSegment() {
        let l = Line(p0: Point(x: 1.0, y: 2.0), p1: Point(x: 2.0, y: 3.0))
        let c = Cubic(line: l)
        XCTAssertEqual(c.p0, l.p0)
        let oneThird = 1.0 / 3.0
        let twoThirds = 2.0 / 3.0
        XCTAssertEqual(c.p1, twoThirds * l.p0 + oneThird * l.p1)
        XCTAssertEqual(c.p2, oneThird * l.p0 + twoThirds * l.p1)
        XCTAssertEqual(c.p3, l.p1)
    }

    func testInitializerQuadratic() {
        let q = Quad(p0: Point(x: 1.0, y: 1.0), p1: Point(x: 2.0, y: 2.0), p2: Point(x: 3.0, y: 1.0))
        let c = Cubic(quad: q)
        let epsilon = 1.0e-6
        // check for equality via lookup table
        let steps = 10
        for (p1, p2) in zip(q.generateLookupTable(withSteps: steps), c.generateLookupTable(withSteps: steps)) {
            XCTAssert((p1 - p2).magnitude < epsilon)
        }
        // check for proper values in control points
        let fiveThirds = 5.0 / 3.0
        let sevenThirds = 7.0 / 3.0
        XCTAssert((c.p0 - Point(x: 1.0, y: 1.0)).magnitude < epsilon)
        XCTAssert((c.p1 - Point(x: fiveThirds, y: fiveThirds)).magnitude < epsilon)
        XCTAssert((c.p2 - Point(x: sevenThirds, y: fiveThirds)).magnitude < epsilon)
        XCTAssert((c.p3 - Point(x: 3.0, y: 1.0)).magnitude < epsilon)
    }

    func testInitializerStartEndMidTStrutLength() {

        let epsilon = 0.00001

        let from = Point(x: 1.0, y: 1.0)
        let mid = Point(x: 2.0, y: 2.0)
        let to = Point(x: 4.0, y: 0.0)

        // first test passing without passing a t or d paramter
        var c = Cubic(from: from, to: to, mid: mid)
        XCTAssertEqual(c.point(at: 0.0), from)
        XCTAssert((c.point(at: 0.5) - mid).magnitude < epsilon)
        XCTAssertEqual(c.point(at: 1.0), to)

        // now test passing in a manual t and length d
        let t = 7.0 / 9.0
        let d = 1.5
        c = Cubic(from: from, to: to, mid: mid, t: t, d: d)
        XCTAssertEqual(c.point(at: 0.0), from)
        XCTAssert((c.point(at: t) - mid).magnitude < epsilon)
        XCTAssertEqual(c.point(at: 1.0), to)
        // make sure our solution has the proper strut length
        let e1 = c.hull(t)[7]
        let e2 = c.hull(t)[8]
        let l = (e2 - e1).magnitude
        XCTAssertEqual(l, d * 1.0 / t, accuracy: epsilon)
    }

    func testBasicProperties() {
        let c = Cubic(p0: Point(x: 1.0, y: 1.0), p1: Point(x: 3.0, y: 2.0), p2: Point(x: 4.0, y: 2.0), p3: Point(x: 6.0, y: 1.0))
        XCTAssert(c.isSimple)
        XCTAssertEqual(c.order, 3)
        XCTAssertEqual(c.from, Point(x: 1.0, y: 1.0))
        XCTAssertEqual(c.to, Point(x: 6.0, y: 1.0))
    }

    func testSimple() {
        // create a simple cubic curve (very simple, because it's equal to a line segment)
        let c1 = Cubic(p0: Point(x: 1.0, y: 1.0), p1: Point(x: 2.0, y: 2.0), p2: Point(x: 3.0, y: 3.0), p3: Point(x: 4.0, y: 4.0))
        XCTAssert(c1.isSimple == true)
        // a non-trivial example of a simple curve -- almost a straight line
        let c2 = Cubic(p0: Point(x: 1.0, y: 1.0), p1: Point(x: 2.0, y: 1.05), p2: Point(x: 3.0, y: 1.05), p3: Point(x: 4.0, y: 1.0))
        XCTAssert(c2.isSimple == true)
        // non-simple curve, control points fall on different sides of the baseline
        let c3 = Cubic(p0: Point(x: 1.0, y: 1.0), p1: Point(x: 2.0, y: 1.05), p2: Point(x: 3.0, y: 0.95), p3: Point(x: 4.0, y: 1.0))
        XCTAssert(c3.isSimple == false)
        // non-simple curve, angle between end point normals > 60 degrees (pi/3) -- in this case the angle is 45 degrees (pi/2)
        let c4 = Cubic(p0: Point(x: 1.0, y: 1.0), p1: Point(x: 1.0, y: 2.0), p2: Point(x: 2.0, y: 3.0), p3: Point(x: 3.0, y: 3.0))
        XCTAssert(c4.isSimple == false)
    }

    func testDerivative() {
        let epsilon = 0.00001
        let p0 = Point(x: 1.0, y: 1.0)
        let p1 = Point(x: 3.0, y: 2.0)
        let p2 = Point(x: 5.0, y: 2.0)
        let p3 = Point(x: 7.0, y: 1.0)
        let c = Cubic(p0: p0, p1: p1, p2: p2, p3: p3)
        XCTAssert((c.vector(at: 0.0) - 3.0 * (p1 - p0)).magnitude < epsilon)
        XCTAssert((c.vector(at: 0.5) - Point(x: 6.0, y: 0.0)).magnitude < epsilon)
        XCTAssert((c.vector(at: 1.0) - 3.0 * (p3 - p2)).magnitude < epsilon)
    }

    func testSplitFromTo() {
        let epsilon = 0.00001
        let c = Cubic(p0: Point(x: 1.0, y: 1.0), p1: Point(x: 3.0, y: 2.0), p2: Point(x: 4.0, y: 2.0), p3: Point(x: 6.0, y: 1.0))
        let t1 = 1.0 / 3.0
        let t2 = 2.0 / 3.0
        let s = c.split(from: t1, to: t2)
        XCTAssert(TestHelpers.curve(s, matchesCurve: c, overInterval: t1 .. t2, tolerance: epsilon))
    }

    func testSplitAt() {
        let epsilon = 0.00001
        let c = Cubic(p0: Point(x: 1.0, y: 1.0), p1: Point(x: 3.0, y: 2.0), p2: Point(x: 4.0, y: 2.0), p3: Point(x: 6.0, y: 1.0))
        let t = 0.25
        let (left, right) = c.split(at: t)
        XCTAssert(TestHelpers.curve(left, matchesCurve: c, overInterval: 0 .. t, tolerance: epsilon))
        XCTAssert(TestHelpers.curve(right, matchesCurve: c, overInterval: t .. 1, tolerance: epsilon))
    }

    func testBoundingBox() {
        // hits codepath where midpoint pushes up y coordinate of bounding box
        let c1 = Cubic(p0: Point(x: 1.0, y: 1.0), p1: Point(x: 3.0, y: 2.0), p2: Point(x: 5.0, y: 2.0), p3: Point(x: 7.0, y: 1.0))
        let expectedBoundingBox1 = BoundingBox(p1: Point(x: 1.0, y: 1.0),
                                               p2: Point(x: 7.0, y: 1.75))
        XCTAssertEqual(c1.boundingBox, expectedBoundingBox1)
        // hits codepath where midpoint pushes down x coordinate of bounding box
        let c2 = Cubic(p0: Point(x: 1.0, y: 1.0), p1: Point(x: -3.0, y: 2.0), p2: Point(x: -3.0, y: 3.0), p3: Point(x: 1.0, y: 4.0))
        let expectedBoundingBox2 = BoundingBox(p1: Point(x: -2.0, y: 1.0),
                                               p2: Point(x: 1.0, y: 4.0))
        XCTAssertEqual(c2.boundingBox, expectedBoundingBox2)
        // this one is designed to hit an unusual codepath: c3 has an extrema that would expand the bounding box,
        // but it falls outside of the range 0<=t<=1, and therefore must be excluded
        let c3 = c1.split(at: 0.25).left
        let expectedBoundingBox3 = BoundingBox(p1: Point(x: 1.0, y: 1.0),
                                               p2: Point(x: 2.5, y: 1.5625))
        XCTAssertEqual(c3.boundingBox, expectedBoundingBox3)
    }

    func testCompute() {
        let c = Cubic(p0: Point(x: 3.0, y: 5.0),
                                 p1: Point(x: 4.0, y: 6.0),
                                 p2: Point(x: 6.0, y: 6.0),
                                 p3: Point(x: 7.0, y: 5.0))
        XCTAssertEqual(c.point(at: 0.0), Point(x: 3.0, y: 5.0))
        XCTAssertEqual(c.point(at: 0.5), Point(x: 5.0, y: 5.75))
        XCTAssertEqual(c.point(at: 1.0), Point(x: 7.0, y: 5.0))
    }

    // -- MARK: - methods for which default implementations provided by protocol

    func testLength() {
        let epsilon = 0.00001
        let c1 = Cubic(p0: Point(x: 1.0, y: 2.0),
                                  p1: Point(x: 7.0 / 3.0, y: 3.0),
                                  p2: Point(x: 11.0 / 3.0, y: 4.0),
                                  p3: Point(x: 5.0, y: 5.0)
        ) // represents a straight line of length 5 -- most curves won't have an easy reference solution
        XCTAssertEqual(c1.length, 5.0, accuracy: epsilon)
    }

    func testExtrema() {
        let f: [Double] = [1, -1, 0, 0] // f(t) = t^3 - t^2, which has two local minimum at t=0, t=2/3 and an inflection point t=1/3
        let g: [Double] = [3, -2, 0, 0] // g(t) = 3t^3 - 2t^2, which has a local minimum at t=0, t=4/9 and an inflection point at t=2/9
        let c = TestHelpers.cubicBezierCurveFromPolynomials(f, g)
        let (xyz, values) = c.extrema
        XCTAssert(xyz.count == 2) // one array for each dimension
        XCTAssertEqual(xyz[0].count, 3)
        XCTAssertEqual(xyz[1].count, 3)
        XCTAssertEqual(values.count, 5)
        XCTAssertEqual(values[0], 0.0)
        XCTAssertEqual(values[1], 2.0 / 9.0)
        XCTAssertEqual(values[2], 1.0 / 3.0)
        XCTAssertEqual(values[3], 4.0 / 9.0)
        XCTAssertEqual(values[4], 2.0 / 3.0)
        XCTAssertEqual(xyz[0].count, 3)
        XCTAssertEqual(xyz[0][0], 0.0)
        XCTAssertEqual(xyz[0][1], 1.0 / 3.0)
        XCTAssertEqual(xyz[0][2], 2.0 / 3.0)
        XCTAssertEqual(xyz[1].count, 3)
        XCTAssertEqual(xyz[1][0], 0.0)
        XCTAssertEqual(xyz[1][1], 2.0 / 9.0)
        XCTAssertEqual(xyz[1][2], 4.0 / 9.0)
        // TODO: originally this test used g = [0, 3, -2, 0] but that exposed a flaw in droots because we were passing in a quadratic. We need to fix this in droots
    }

    // TODO: we still have some missing unit tests for Cubic's API entry points

    //    func testHull() {
    //        let l = Line(p0: Point(x: 1.0, y: 2.0), p1: Point(x: 3.0, y: 4.0))
    //        let h = l.hull(0.5)
    //        XCTAssert(h.count == 3)
    //        XCTAssertEqual(h[0], Point(x: 1.0, y: 2.0))
    //        XCTAssertEqual(h[1], Point(x: 3.0, y: 4.0))
    //        XCTAssertEqual(h[2], Point(x: 2.0, y: 3.0))
    //    }
    //
    //    func testNormal() {
    //        let l = Line(p0: Point(x: 1.0, y: 2.0), p1: Point(x: 5.0, y: 6.0))
    //        let n1 = l.normal(0.0)
    //        let n2 = l.normal(0.5)
    //        let n3 = l.normal(1.0)
    //        XCTAssertEqual(n1, Point(x: -1.0 / sqrt(2.0), y: 1.0 / sqrt(2.0)))
    //        XCTAssertEqual(n1, n2)
    //        XCTAssertEqual(n2, n3)
    //    }
    //
    //    func testReduce() {
    //        let l = Line(p0: Point(x: 1.0, y: 2.0), p1: Point(x: 5.0, y: 6.0))
    //        let r = l.reduce() // reduce should just return the original line back
    //        XCTAssertEqual(r.count, 1)
    //        XCTAssertEqual(r[0].t1, 0.0)
    //        XCTAssertEqual(r[0].t2, 1.0)
    //        XCTAssertEqual(r[0].curve, l)
    //    }
    //
    //    //    func testScaleDistanceFunc {
    //    //
    //    //    }
    //
    //    func testProject() {
    //        let l = Line(p0: Point(x: 1.0, y: 2.0), p1: Point(x: 5.0, y: 6.0))
    //        let p1 = l.project(point: Point(x: 0.0, y: 0.0)) // should project to p0
    //        XCTAssertEqual(p1, Point(x: 1.0, y: 2.0))
    //        let p2 = l.project(point: Point(x: 1.0, y: 4.0)) // should project to l.point(at: 0.25)
    //        XCTAssertEqual(p2, Point(x: 2.0, y: 3.0))
    //        let p3 = l.project(point: Point(x: 6.0, y: 7.0))
    //        XCTAssertEqual(p3, Point(x: 5.0, y: 6.0)) // should project to p1
    //    }
    //
    //    func testIntersects() {
    //        let l = Line(p0: Point(x: 1.0, y: 2.0), p1: Point(x: 5.0, y: 6.0))
    //        let i = l.intersects()
    //        XCTAssert(i.count == 0) // lines never self-intersect
    //    }
    //
    //    // -- MARK: - line-curve intersection tests
    //
    //    func testIntersectsQuadratic() {
    //        // we mostly just care that we call into the proper implementation and that the results are ordered correctly
    //        // q is a quadratic where y(x) = 2 - 2(x-1)^2
    //        let epsilon = 0.00001
    //        let q: QuadraticBezierCurve = QuadraticBezierCurve.init(p0: Point(x: 0.0, y: 0.0),
    //                                                                p1: Point(x: 1.0, y: 2.0),
    //                                                                p2: Point(x: 2.0, y: 0.0),
    //                                                                t: 0.5)
    //        let l1: Line = Line(p0: Point(x: -1.0, y: 1.0), p1: Point(x: 3.0, y: 1.0))
    //        let l2: Line = Line(p0: Point(x: 3.0, y: 1.0), p1: Point(x: -1.0, y: 1.0)) // same line as l1, but reversed
    //        // the intersections for both lines occur at x = 1±sqrt(1/2)
    //        let i1 = l1.intersects(curve: q)
    //        let r1 = 1.0 - sqrt(1.0 / 2.0)
    //        let r2 = 1.0 + sqrt(1.0 / 2.0)
    //        XCTAssertEqual(i1.count, 2)
    //        XCTAssertEqualWithAccuracy(i1[0].t1, (r1 + 1.0) / 4.0, accuracy: epsilon)
    //        XCTAssertEqualWithAccuracy(i1[0].t2, r1 / 2.0, accuracy: epsilon)
    //        XCTAssert((l1.point(at: i1[0].t1) - q.point(at: i1[0].t2)).magnitude < epsilon)
    //        XCTAssertEqualWithAccuracy(i1[1].t1, (r2 + 1.0) / 4.0, accuracy: epsilon)
    //        XCTAssertEqualWithAccuracy(i1[1].t2, r2 / 2.0, accuracy: epsilon)
    //        XCTAssert((l1.point(at: i1[1].t1) - q.point(at: i1[1].t2)).magnitude < epsilon)
    //        // do the same thing as above but using l2
    //        let i2 = l2.intersects(curve: q)
    //        XCTAssertEqual(i2.count, 2)
    //        XCTAssertEqualWithAccuracy(i2[0].t1, (r1 + 1.0) / 4.0, accuracy: epsilon)
    //        XCTAssertEqualWithAccuracy(i2[0].t2, r2 / 2.0, accuracy: epsilon)
    //        XCTAssert((l2.point(at: i2[0].t1) - q.point(at: i2[0].t2)).magnitude < epsilon)
    //        XCTAssertEqualWithAccuracy(i2[1].t1, (r2 + 1.0) / 4.0, accuracy: epsilon)
    //        XCTAssertEqualWithAccuracy(i2[1].t2, r1 / 2.0, accuracy: epsilon)
    //        XCTAssert((l2.point(at: i2[1].t1) - q.point(at: i2[1].t2)).magnitude < epsilon)
    //    }
    //
    //    func testIntersectsCubic() {
    //        // we mostly just care that we call into the proper implementation and that the results are ordered correctly
    //        let epsilon = 0.00001
    //        let c: Cubic = Cubic(p0: Point(x: -1, y: 0),
    //                                                   p1: Point(x: -1, y: 1),
    //                                                   p2: Point(x:  1, y: -1),
    //                                                   p3: Point(x:  1, y: 0))
    //        let l1: Line = Line(p0: Point(x: -2.0, y: 0.0), p1: Point(x: 2.0, y: 0.0))
    //        let i1 = l1.intersects(curve: c)
    //
    //        XCTAssertEqual(i1.count, 3)
    //        XCTAssertEqualWithAccuracy(i1[0].t1, 0.25, accuracy: epsilon)
    //        XCTAssertEqualWithAccuracy(i1[0].t2, 0.0, accuracy: epsilon)
    //        XCTAssertEqualWithAccuracy(i1[1].t1, 0.5, accuracy: epsilon)
    //        XCTAssertEqualWithAccuracy(i1[1].t2, 0.5, accuracy: epsilon)
    //        XCTAssertEqualWithAccuracy(i1[2].t1, 0.75, accuracy: epsilon)
    //        XCTAssertEqualWithAccuracy(i1[2].t2, 1.0, accuracy: epsilon)
    //        // l2 is the same line going in the opposite direction
    //        // by checking this we ensure the intersections are ordered by the line and not the cubic
    //        let l2: Line = Line(p0: Point(x: 2.0, y: 0.0), p1: Point(x: -2.0, y: 0.0))
    //        let i2 = l2.intersects(curve: c)
    //        XCTAssertEqual(i2.count, 3)
    //        XCTAssertEqualWithAccuracy(i2[0].t1, 0.25, accuracy: epsilon)
    //        XCTAssertEqualWithAccuracy(i2[0].t2, 1.0, accuracy: epsilon)
    //        XCTAssertEqualWithAccuracy(i2[1].t1, 0.5, accuracy: epsilon)
    //        XCTAssertEqualWithAccuracy(i2[1].t2, 0.5, accuracy: epsilon)
    //        XCTAssertEqualWithAccuracy(i2[2].t1, 0.75, accuracy: epsilon)
    //        XCTAssertEqualWithAccuracy(i2[2].t2, 0.0, accuracy: epsilon)
    //    }
    //

    func testCubicIntersectsLine() {
        let epsilon = 0.00001
        let c: Cubic = Cubic(p0: Point(x: -1, y: 0),
                                                   p1: Point(x: -1, y: 1),
                                                   p2: Point(x:  1, y: -1),
                                                   p3: Point(x:  1, y: 0))
        let l: Curve = Line(p0: Point(x: -2.0, y: 0.0), p1: Point(x: 2.0, y: 0.0))
        let i = c.intersects(curve: l)

        XCTAssertEqual(i.count, 3)
        XCTAssertEqual(i[0].t2, 0.25, accuracy: epsilon)
        XCTAssertEqual(i[0].t1, 0.0, accuracy: epsilon)
        XCTAssertEqual(i[1].t2, 0.5, accuracy: epsilon)
        XCTAssertEqual(i[1].t1, 0.5, accuracy: epsilon)
        XCTAssertEqual(i[2].t2, 0.75, accuracy: epsilon)
        XCTAssertEqual(i[2].t1, 1.0, accuracy: epsilon)
    }

    // MARK: -

    func testEquatable() {
        let p0 = Point(x: 1.0, y: 2.0)
        let p1 = Point(x: 2.0, y: 3.0)
        let p2 = Point(x: 3.0, y: 3.0)
        let p3 = Point(x: 4.0, y: 2.0)

        let c1 = Cubic(p0: p0, p1: p1, p2: p2, p3: p3)
        let c2 = Cubic(p0: Point(x: 5.0, y: 6.0), p1: p1, p2: p2, p3: p3)
        let c3 = Cubic(p0: p0, p1: Point(x: 1.0, y: 3.0), p2: p2, p3: p3)
        let c4 = Cubic(p0: p0, p1: p1, p2: Point(x: 3.0, y: 6.0), p3: p3)
        let c5 = Cubic(p0: p0, p1: p1, p2: p2, p3: Point(x: -4.0, y: 2.0))

        XCTAssertEqual(c1, c1)
        XCTAssertNotEqual(c1, c2)
        XCTAssertNotEqual(c1, c3)
        XCTAssertNotEqual(c1, c4)
        XCTAssertNotEqual(c1, c5)
    }
}
