//
//  LineTests.swift
//  WolfPaths_Tests
//
//  Created by Wolf McNally on 11/18/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
import WolfPaths
import WolfGeometry

class LineTests: XCTestCase {
    func testInitializerArray() {
        let l = Line(points: [Point(x: 1.0, y: 1.0), Point(x: 3.0, y: 2.0)])
        XCTAssertEqual(l.p0, Point(x: 1.0, y: 1.0))
        XCTAssertEqual(l.p1, Point(x: 3.0, y: 2.0))
        XCTAssertEqual(l.from, Point(x: 1.0, y: 1.0))
        XCTAssertEqual(l.to, Point(x: 3.0, y: 2.0))
    }

    func testInitializerIndividualPoints() {
        let l = Line(p0: Point(x: 1.0, y: 1.0), p1: Point(x: 3.0, y: 2.0))
        XCTAssertEqual(l.p0, Point(x: 1.0, y: 1.0))
        XCTAssertEqual(l.p1, Point(x: 3.0, y: 2.0))
        XCTAssertEqual(l.from, Point(x: 1.0, y: 1.0))
        XCTAssertEqual(l.to, Point(x: 3.0, y: 2.0))
    }

    func testBasicProperties() {
        let l = Line(p0: Point(x: 1.0, y: 1.0), p1: Point(x: 2.0, y: 5.0))
        XCTAssert(l.isSimple)
        XCTAssertEqual(l.order, 1)
        XCTAssertEqual(l.from, Point(x: 1.0, y: 1.0))
        XCTAssertEqual(l.to, Point(x: 2.0, y: 5.0))
    }

    func testVector() {
        let l = Line(p0: Point(x: 1.0, y: 1.0), p1: Point(x: 3.0, y: 2.0))
        XCTAssertEqual(l.vector(at: 0.23), Vector(dx: 2.0, dy: 1.0))
    }

    func testSplitFromTo() {
        let l = Line(p0: Point(x: 1.0, y: 1.0), p1: Point(x: 4.0, y: 7.0))
        let t1 = 1.0 / 3.0
        let t2 = 2.0 / 3.0
        let s = l.split(from: t1, to: t2)
        XCTAssertEqual(s, Line(p0: Point(x: 2.0, y: 3.0), p1: Point(x: 3.0, y: 5.0)))
    }

    func testSplitAt() {
        let l = Line(p0: Point(x: 1.0, y: 1.0), p1: Point(x: 3.0, y: 5.0))
        let (left, right) = l.split(at: 0.5)
        XCTAssertEqual(left, Line(p0: Point(x: 1.0, y: 1.0), p1: Point(x: 2.0, y: 3.0)))
        XCTAssertEqual(right, Line(p0: Point(x: 2.0, y: 3.0), p1: Point(x: 3.0, y: 5.0)))
    }

    func testBoundingBox() {
        let l = Line(p0: Point(x: 3.0, y: 5.0), p1: Point(x: 1.0, y: 3.0))
        XCTAssertEqual(l.boundingBox, BoundingBox(p1: Point(x: 1.0, y: 3.0), p2: Point(x: 3.0, y: 5.0)))
    }

    func testCompute() {
        let l = Line(p0: Point(x: 3.0, y: 5.0), p1: Point(x: 1.0, y: 3.0))
        XCTAssertEqual(l.point(at: 0.0), Point(x: 3.0, y: 5.0))
        XCTAssertEqual(l.point(at: 0.5), Point(x: 2.0, y: 4.0))
        XCTAssertEqual(l.point(at: 1.0), Point(x: 1.0, y: 3.0))
    }

    func testLength() {
        let l = Line(p0: Point(x: 1.0, y: 2.0), p1: Point(x: 4.0, y: 6.0))
        XCTAssertEqual(l.length, 5.0)
    }

    func testExtrema() {
        let l = Line(p0: Point(x: 1.0, y: 2.0), p1: Point(x: 4.0, y: 6.0))
        let (xyz, values) = l.extrema
        XCTAssertEqual(xyz.count, 2) // one array for each dimension
        XCTAssertEqual(xyz[0].count, 2)
        XCTAssertEqual(xyz[1].count, 2)
        XCTAssertEqual(values.count, 2) // two extrema total
        XCTAssertEqual(values[0], 0.0)
        XCTAssertEqual(values[1], 1.0)
        XCTAssertEqual(xyz[0][0], 0.0)
        XCTAssertEqual(xyz[0][1], 1.0)
        XCTAssertEqual(xyz[1][0], 0.0)
        XCTAssertEqual(xyz[1][1], 1.0)
    }

    func testHull() {
        let l = Line(p0: Point(x: 1.0, y: 2.0), p1: Point(x: 3.0, y: 4.0))
        let h = l.hull(0.5)
        XCTAssert(h.count == 3)
        XCTAssertEqual(h[0], Point(x: 1.0, y: 2.0))
        XCTAssertEqual(h[1], Point(x: 3.0, y: 4.0))
        XCTAssertEqual(h[2], Point(x: 2.0, y: 3.0))
    }

    func testNormal() {
        let l = Line(p0: Point(x: 1.0, y: 2.0), p1: Point(x: 5.0, y: 6.0))
        let n1 = l.normal(at: 0.0)
        let n2 = l.normal(at: 0.5)
        let n3 = l.normal(at: 1.0)
        XCTAssertEqual(n1, Vector(dx: -1.0 / sqrt(2.0), dy: 1.0 / sqrt(2.0)))
        XCTAssertEqual(n1, n2)
        XCTAssertEqual(n2, n3)
    }

    func testReduce() {
        let l = Line(p0: Point(x: 1.0, y: 2.0), p1: Point(x: 5.0, y: 6.0))
        let r = l.reduce() // reduce should just return the original line back
        XCTAssertEqual(r.count, 1)
        XCTAssertEqual(r[0].t1, 0.0)
        XCTAssertEqual(r[0].t2, 1.0)
        XCTAssertEqual(r[0].curve, l)
    }

    func testIntersects() {
        let l = Line(p0: Point(x: 1.0, y: 2.0), p1: Point(x: 5.0, y: 6.0))
        let i = l.selfIntersections()
        XCTAssert(i.count == 0) // lines never self-intersect
    }

    func testEquatable() {
        let l1 = Line(p0: Point(x: 1.0, y: 2.0), p1: Point(x: 3.0, y: 4.0))
        let l2 = Line(p0: Point(x: 1.0, y: 3.0), p1: Point(x: 3.0, y: 4.0))
        let l3 = Line(p0: Point(x: 1.0, y: 2.0), p1: Point(x: 3.0, y: 5.0))
        XCTAssertEqual(l1, l1)
        XCTAssertNotEqual(l1, l2)
        XCTAssertNotEqual(l1, l3)
    }
}
