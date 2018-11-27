//
//  LineCurveIntersectionTests.swift
//  WolfPaths_Tests
//
//  Created by Wolf McNally on 11/18/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
import WolfPaths
import WolfGeometry

class LineCurveIntersectionTests: XCTestCase {
    func testIntersectsQuadratic() {
        // we mostly just care that we call into the proper implementation and that the results are ordered correctly
        // q is a quadratic where y(x) = 2 - 2(x-1)^2
        let epsilon = 0.00001
        let q = Quad(from: Point(x: 0.0, y: 0.0),
                     to: Point(x: 2.0, y: 0.0),
                     mid: Point(x: 1.0, y: 2.0),
                     t: 0.5)
        let l1 = Line(p0: Point(x: -1.0, y: 1.0), p1: Point(x: 3.0, y: 1.0))
        let l2 = Line(p0: Point(x: 3.0, y: 1.0), p1: Point(x: -1.0, y: 1.0)) // same line as l1, but reversed
        // the intersections for both lines occur at x = 1±sqrt(1/2)
        let i1 = l1.intersects(curve: q)
        let r1 = 1.0 - sqrt(1.0 / 2.0)
        let r2 = 1.0 + sqrt(1.0 / 2.0)
        XCTAssertEqual(i1.count, 2)
        XCTAssertEqual(i1[0].t1, (r1 + 1.0) / 4.0, accuracy: epsilon)
        XCTAssertEqual(i1[0].t2, r1 / 2.0, accuracy: epsilon)
        XCTAssert((l1.point(at: i1[0].t1) - q.point(at: i1[0].t2)).magnitude < epsilon)
        XCTAssertEqual(i1[1].t1, (r2 + 1.0) / 4.0, accuracy: epsilon)
        XCTAssertEqual(i1[1].t2, r2 / 2.0, accuracy: epsilon)
        XCTAssert((l1.point(at: i1[1].t1) - q.point(at: i1[1].t2)).magnitude < epsilon)
        // do the same thing as above but using l2
        let i2 = l2.intersects(curve: q)
        XCTAssertEqual(i2.count, 2)
        XCTAssertEqual(i2[0].t1, (r1 + 1.0) / 4.0, accuracy: epsilon)
        XCTAssertEqual(i2[0].t2, r2 / 2.0, accuracy: epsilon)
        XCTAssert((l2.point(at: i2[0].t1) - q.point(at: i2[0].t2)).magnitude < epsilon)
        XCTAssertEqual(i2[1].t1, (r2 + 1.0) / 4.0, accuracy: epsilon)
        XCTAssertEqual(i2[1].t2, r1 / 2.0, accuracy: epsilon)
        XCTAssert((l2.point(at: i2[1].t1) - q.point(at: i2[1].t2)).magnitude < epsilon)
    }

    func testIntersectsCubic() {
        // we mostly just care that we call into the proper implementation and that the results are ordered correctly
        let epsilon = 0.00001
        let c = Cubic(p0: Point(x: -1, y: 0),
                      p1: Point(x: -1, y: 1),
                      p2: Point(x:  1, y: -1),
                      p3: Point(x:  1, y: 0))
        let l1 = Line(p0: Point(x: -2.0, y: 0.0), p1: Point(x: 2.0, y: 0.0))
        let i1 = l1.intersects(curve: c)

        XCTAssertEqual(i1.count, 3)
        XCTAssertEqual(i1[0].t1, 0.25, accuracy: epsilon)
        XCTAssertEqual(i1[0].t2, 0.0, accuracy: epsilon)
        XCTAssertEqual(i1[1].t1, 0.5, accuracy: epsilon)
        XCTAssertEqual(i1[1].t2, 0.5, accuracy: epsilon)
        XCTAssertEqual(i1[2].t1, 0.75, accuracy: epsilon)
        XCTAssertEqual(i1[2].t2, 1.0, accuracy: epsilon)
        // l2 is the same line going in the opposite direction
        // by checking this we ensure the intersections are ordered by the line and not the cubic
        let l2 = Line(p0: Point(x: 2.0, y: 0.0), p1: Point(x: -2.0, y: 0.0))
        let i2 = l2.intersects(curve: c)
        XCTAssertEqual(i2.count, 3)
        XCTAssertEqual(i2[0].t1, 0.25, accuracy: epsilon)
        XCTAssertEqual(i2[0].t2, 1.0, accuracy: epsilon)
        XCTAssertEqual(i2[1].t1, 0.5, accuracy: epsilon)
        XCTAssertEqual(i2[1].t2, 0.5, accuracy: epsilon)
        XCTAssertEqual(i2[2].t1, 0.75, accuracy: epsilon)
        XCTAssertEqual(i2[2].t2, 0.0, accuracy: epsilon)
    }

    func testIntersectsDegenerateCubic1() {
        // a special case where the cubic is degenerate (it can actually be described as a quadratic)
        let epsilon = 0.00001
        let fiveThirds = 5.0 / 3.0
        let sevenThirds = 7.0 / 3.0
        let c = Cubic(p0: Point(x: 1.0, y: 1.0),
                      p1: Point(x: fiveThirds, y: fiveThirds),
                      p2: Point(x: sevenThirds, y: fiveThirds),
                      p3: Point(x: 3.0, y: 1.0))
        let l = Line(p0: Point(x:1.0, y: 1.1), p1: Point(x: 3.0, y: 1.1))
        let i = l.intersects(curve: c)
        XCTAssertEqual(i.count, 2)
        XCTAssert(TestHelpers.intersections(i, betweenCurve: l, andOtherCurve: c, areWithinTolerance: epsilon))
    }

    func testIntersectsDegenerateCubic2() {
        // a special case where the cubic is degenerate (it can actually be described as a line)
        let epsilon = 0.00001
        let c = Cubic(p0: Point(x: 1.0, y: 1.0),
                      p1: Point(x: 2.0, y: 2.0),
                      p2: Point(x: 3.0, y: 3.0),
                      p3: Point(x: 4.0, y: 4.0))
        let l = Line(p0: Point(x:1.0, y: 2.0), p1: Point(x: 4.0, y: 2.0))
        let i = l.intersects(curve: c)
        XCTAssertEqual(i.count, 1)
        XCTAssert(TestHelpers.intersections(i, betweenCurve: l, andOtherCurve: c, areWithinTolerance: epsilon))
    }
}
