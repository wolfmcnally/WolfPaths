//
//  QuadTests.swift
//  WolfPaths_Tests
//
//  Created by Wolf McNally on 11/18/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
import WolfPaths
import WolfGeometry

class QuadTests: XCTestCase {

    // TODO: we still have a LOT of missing unit tests for Quad's API entry points

    func testInitializerFromToMidT() {
        let q1 = Quad(from: Point(x: 1.0, y: 1.0), to: Point(x: 5.0, y: 1.0), mid: Point(x: 3.0, y: 2.0), t: 0.5)
        XCTAssertEqual(q1, Quad(p0: Point(x: 1.0, y: 1.0), p1: Point(x: 3.0, y: 3.0), p2: Point(x: 5.0, y: 1.0)))
        // degenerate cases
        let q2 = Quad(from: Point(x: 1.0, y: 1.0), to: Point(x: 5.0, y: 1.0), mid: Point(x: 1.0, y: 1.0), t: 0.0)
        XCTAssertEqual(q2, Quad(p0: Point(x: 1.0, y: 1.0), p1: Point(x: 1.0, y: 1.0), p2: Point(x: 5.0, y: 1.0)))
        let q3 = Quad(from: Point(x: 1.0, y: 1.0), to: Point(x: 5.0, y: 1.0), mid: Point(x: 5.0, y: 1.0), t: 1.0)
        XCTAssertEqual(q3, Quad(p0: Point(x: 1.0, y: 1.0), p1: Point(x: 5.0, y: 1.0), p2: Point(x: 5.0, y: 1.0)))
    }

    func testBasicProperties() {
        let q = Quad(p0: Point(x: 1.0, y: 1.0), p1: Point(x: 3.5, y: 2.0), p2: Point(x: 6.0, y: 1.0))
        XCTAssert(q.isSimple)
        XCTAssertEqual(q.order, 2)
        XCTAssertEqual(q.from, Point(x: 1.0, y: 1.0))
        XCTAssertEqual(q.to, Point(x: 6.0, y: 1.0))
    }

    //    func testSimple() {
    //    }
    //
    //    func testDerivative() {
    //    }
    //
    //    func testSplitFromTo() {
    //    }
    //
    //    func testSplitAt() {
    //    }
    //
    func testBoundingBox() {
        // hits codepath where midpoint pushes up y coordinate of bounding box
        let q1 = Quad(p0: Point(x: 1.0, y: 1.0), p1: Point(x: 3.0, y: 3.0), p2: Point(x: 5.0, y: 1.0))
        let expectedBoundingBox1 = BoundingBox(p1: Point(x: 1.0, y: 1.0),
                                               p2: Point(x: 5.0, y: 2.0))
        XCTAssertEqual(q1.boundingBox, expectedBoundingBox1)

        // hits codepath where midpoint pushes down x coordinate of bounding box
        let q2 = Quad(p0: Point(x: 1.0, y: 1.0), p1: Point(x: -1.0, y: 2.0), p2: Point(x: 1.0, y: 3.0))
        let expectedBoundingBox2 = BoundingBox(p1: Point(x: 0.0, y: 1.0),
                                               p2: Point(x: 1.0, y: 3.0))
        XCTAssertEqual(q2.boundingBox, expectedBoundingBox2)
        // this one is designed to hit an unusual codepath: c3 has an extrema that would expand the bounding box,
        // but it falls outside of the range 0<=t<=1, and therefore must be excluded
        let q3 = q1.split(at: 0.25).left
        let expectedBoundingBox3 = BoundingBox(p1: Point(x: 1.0, y: 1.0),
                                               p2: Point(x: 2.0, y: 1.75))
        XCTAssertEqual(q3.boundingBox, expectedBoundingBox3)
    }
    //
    //    func testCompute() {
    //    }

    // -- MARK: - methods for which default implementations provided by protocol

    //    func testLength() {
    //    }
    //
    //    func testExtrema() {
    //    }
    //
    //    func testHull() {
    //    }
    //
    //    func testNormal() {
    //    }
    //
    //    func testReduce() {
    //    }
    //
    //    func testScaleDistanceFunc {
    //    }
    //
    //    func testProject() {
    //    }
    //
    //    // -- MARK: - line-curve intersection tests
    //
    //    func testIntersectsQuadratic() {
    //        // we mostly just care that we call into the proper implementation and that the results are ordered correctly
    //        // q is a quadratic where y(x) = 2 - 2(x-1)^2
    //        let epsilon: CGFloat = 0.00001
    //        let q: Quad = Quad.init(p0: Point(x: 0.0, y: 0.0),
    //                                                                p1: Point(x: 1.0, y: 2.0),
    //                                                                p2: Point(x: 2.0, y: 0.0),
    //                                                                t: 0.5)
    //        let l1: LineSegment = LineSegment(p0: Point(x: -1.0, y: 1.0), p1: Point(x: 3.0, y: 1.0))
    //        let l2: LineSegment = LineSegment(p0: Point(x: 3.0, y: 1.0), p1: Point(x: -1.0, y: 1.0)) // same line as l1, but reversed
    //        // the intersections for both lines occur at x = 1±sqrt(1/2)
    //        let i1 = l1.intersects(curve: q)
    //        let r1: CGFloat = 1.0 - sqrt(1.0 / 2.0)
    //        let r2: CGFloat = 1.0 + sqrt(1.0 / 2.0)
    //        XCTAssertEqual(i1.count, 2)
    //        XCTAssertEqualWithAccuracy(i1[0].t1, (r1 + 1.0) / 4.0, accuracy: epsilon)
    //        XCTAssertEqualWithAccuracy(i1[0].t2, r1 / 2.0, accuracy: epsilon)
    //        XCTAssert((l1.compute(i1[0].t1) - q.compute(i1[0].t2)).length < epsilon)
    //        XCTAssertEqualWithAccuracy(i1[1].t1, (r2 + 1.0) / 4.0, accuracy: epsilon)
    //        XCTAssertEqualWithAccuracy(i1[1].t2, r2 / 2.0, accuracy: epsilon)
    //        XCTAssert((l1.compute(i1[1].t1) - q.compute(i1[1].t2)).length < epsilon)
    //        // do the same thing as above but using l2
    //        let i2 = l2.intersects(curve: q)
    //        XCTAssertEqual(i2.count, 2)
    //        XCTAssertEqualWithAccuracy(i2[0].t1, (r1 + 1.0) / 4.0, accuracy: epsilon)
    //        XCTAssertEqualWithAccuracy(i2[0].t2, r2 / 2.0, accuracy: epsilon)
    //        XCTAssert((l2.compute(i2[0].t1) - q.compute(i2[0].t2)).length < epsilon)
    //        XCTAssertEqualWithAccuracy(i2[1].t1, (r2 + 1.0) / 4.0, accuracy: epsilon)
    //        XCTAssertEqualWithAccuracy(i2[1].t2, r1 / 2.0, accuracy: epsilon)
    //        XCTAssert((l2.compute(i2[1].t1) - q.compute(i2[1].t2)).length < epsilon)
    //    }
    //

    // MARK: -

    func testEquatable() {
        let p0 = Point(x: 1.0, y: 2.0)
        let p1 = Point(x: 2.0, y: 3.0)
        let p2 = Point(x: 3.0, y: 2.0)

        let c1 = Quad(p0: p0, p1: p1, p2: p2)
        let c2 = Quad(p0: p0, p1: p1, p2: p2)
        let c3 = Quad(p0: Point(x: 5.0, y: 6.0), p1: p1, p2: p2)
        let c4 = Quad(p0: p0, p1: Point(x: 1.0, y: 3.0), p2: p2)
        let c5 = Quad(p0: p0, p1: p1, p2: Point(x: 3.0, y: 6.0))

        XCTAssertEqual(c1, c1)
        XCTAssertEqual(c1, c2)
        XCTAssertNotEqual(c1, c3)
        XCTAssertNotEqual(c1, c4)
        XCTAssertNotEqual(c1, c5)
    }
}
