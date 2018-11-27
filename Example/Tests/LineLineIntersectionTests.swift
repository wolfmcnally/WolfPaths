//
//  LineLineIntersectionTests.swift
//  WolfPaths_Tests
//
//  Created by Wolf McNally on 11/18/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
import WolfPaths
import WolfGeometry

class LineLineIntersectionTests: XCTestCase {
    func testIntersectsLineYesInsideInterval() {
        // a normal line-line intersection that happens in the middle of a line
        let l1 = Line(p0: Point(x: 1.0, y: 2.0), p1: Point(x: 7.0, y: 8.0))
        let l2 = Line(p0: Point(x: 1.0, y: 4.0), p1: Point(x: 5.0, y: 0.0))
        let i = l1.intersects(line: l2)
        XCTAssertEqual(i.count, 1)
        XCTAssertEqual(i[0].t1, 1.0 / 6.0)
        XCTAssertEqual(i[0].t2, 1.0 / 4.0)
    }

    func testIntersectsLineNoOutsideInterval1() {
        // two lines that do not intersect because the intersection happens outside the line-segment
        let l1 = Line(p0: Point(x: 1.0, y: 0.0), p1: Point(x: 1.0, y: 2.0))
        let l2 = Line(p0: Point(x: 0.0, y: 2.001), p1: Point(x: 2.0, y: 2.001))
        let i = l1.intersects(line: l2)
        XCTAssertEqual(i.count, 0)
    }

    func testIntersectsLineNoOutsideInterval2() {
        // two lines that do not intersect because the intersection happens outside the *other* line segment
        let l1 = Line(p0: Point(x: 1.0, y: 0.0), p1: Point(x: 1.0, y: 2.0))
        let l2 = Line(p0: Point(x: 2.0, y: 1.0), p1: Point(x: 1.001, y: 1.0))
        let i = l1.intersects(line: l2)
        XCTAssertEqual(i.count, 0)
    }

    func testIntersectsLineYesEdge1() {
        // two lines that intersect on the 1st line's edge
        let l1 = Line(p0: Point(x: 1.0, y: 0.0), p1: Point(x: 1.0, y: 2.0))
        let l2 = Line(p0: Point(x: 2.0, y: 1.0), p1: Point(x: 1.0, y: 1.0))
        let i = l1.intersects(line: l2)
        XCTAssertEqual(i.count, 1)
        XCTAssertEqual(i[0].t1, 0.5)
        XCTAssertEqual(i[0].t2, 1.0)
    }

    func testIntersectsLineYesEdge2() {
        // two lines that intersect on the 2nd line's edge
        let l1 = Line(p0: Point(x: 1.0, y: 0.0), p1: Point(x: 1.0, y: 2.0))
        let l2 = Line(p0: Point(x: 0.0, y: 2.0), p1: Point(x: 2.0, y: 2.0))
        let i = l1.intersects(line: l2)
        XCTAssertEqual(i.count, 1)
        XCTAssertEqual(i[0].t1, 1.0)
        XCTAssertEqual(i[0].t2, 0.5)
    }

    func testIntersectsLineYesLineStart() {
        // two lines that intersect at the start of the first line
        let l1 = Line(p0: Point(x: 1.0, y: 0.0), p1: Point(x: 2.0, y: 1.0))
        let l2 = Line(p0: Point(x: -2.0, y: 2.0), p1: Point(x: 1.0, y: 0.0))
        let i = l1.intersects(line: l2)
        XCTAssertEqual(i.count, 1)
        XCTAssertEqual(i[0].t1, 0.0)
        XCTAssertEqual(i[0].t2, 1.0)
    }

    func testIntersectsLineYesLineEnd() {
        // two lines that intersect at the end of the first line
        let l1 = Line(p0: Point(x: 1.0, y: 0.0), p1: Point(x: 2.0, y: 1.0))
        let l2 = Line(p0: Point(x: 2.0, y: 1.0), p1: Point(x: -2.0, y: 2.0))
        let i = l1.intersects(line: l2)
        XCTAssertEqual(i.count, 1)
        XCTAssertEqual(i[0].t1, 1.0)
        XCTAssertEqual(i[0].t2, 0.0)
    }

    func testIntersectsLineAsCurve() {
        // ensure that intersects(curve:) calls into the proper implementation
        let l1: Line = Line(p0: Point(x: 0.0, y: 0.0), p1: Point(x: 1.0, y: 1.0))
        let l2: Curve = Line(p0: Point(x: 0.0, y: 1.0), p1: Point(x: 1.0, y: 0.0)) as Curve
        let i1 = l1.intersects(curve: l2)
        XCTAssertEqual(i1.count, 1)
        XCTAssertEqual(i1[0].t1, 0.5)
        XCTAssertEqual(i1[0].t2, 0.5)

        let i2 = l2.intersects(curve: l1)
        XCTAssertEqual(i2.count, 1)
        XCTAssertEqual(i2[0].t1, 0.5)
        XCTAssertEqual(i2[0].t2, 0.5)
    }

    func testIntersectsLineNoParallel() {

        // this is a special case where determinant is zero
        let l1 = Line(p0: Point(x: -2.0, y: -1.0), p1: Point(x: 2.0, y: 1.0))
        let l2 = Line(p0: Point(x: -4.0, y: -1.0), p1: Point(x: 4.0, y: 3.0))
        let i1 = l1.intersects(line: l2)
        XCTAssertEqual(i1.count, 0)

        // this is a very, very special case! Not only is the determinant zero, but the *minor* determinants are also zero, so without special care we can get 0*(1/det) = 0*Inf = NaN!
        let l3 = Line(p0: Point(x: -5.0, y: -5.0), p1: Point(x: 5.0, y: 5.0))
        let l4 = Line(p0: Point(x: -1.0, y: -1.0), p1: Point(x: 1.0, y: 1.0))
        let i2 = l3.intersects(line: l4)
        XCTAssertEqual(i2.count, 0)

        // very, very nearly parallel lines
        let l5 = Line(p0: Point(x: 0.0, y: 0.0), p1: Point(x: 1.0, y: 1.0))
        let l6 = Line(p0: Point(x: 0.0, y: 1.0), p1: Point(x: 1.0, y: 2.0 + 1.0e-15))
        let i3 = l5.intersects(line: l6)
        XCTAssertEqual(i3.count, 0)
    }
}
