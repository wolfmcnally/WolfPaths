//
//  SubpathTests.swift
//  WolfPaths_Tests
//
//  Created by Wolf McNally on 11/18/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
import WolfPaths
import WolfGeometry

class SubpathTests: XCTestCase {
    let line1 = Line(p0: Point(x: 1.0, y: 2.0), p1: Point(x: 5.0, y: 5.0))   // length = 5
    let line2 = Line(p0: Point(x: 5.0, y: 5.0), p1: Point(x: 13.0, y: -1.0)) // length = 10

    func testLength() {
        let p = Subpath(curves: [line1, line2])
        XCTAssertEqual(p.length, 15.0) // sum of two lengths
    }

    func testBoundingBox() {
        let p = Subpath(curves: [line1, line2])
        XCTAssertEqual(p.boundingBox, BoundingBox(min: Point(x: 1.0, y: -1.0), max: Point(x: 13.0, y: 5.0))) // just the union of the two bounding boxes
    }

    func testOffset() {
        // construct a PathComponent from a split cubic
        let q = Quad(p0: Point(x: 0.0, y: 0.0), p1: Point(x: 2.0, y: 1.0), p2: Point(x: 4.0, y: 0.0))
        let (ql, qr) = q.split(at: 0.5)
        let p = Subpath(curves: [ql, qr])
        // test that offset gives us the same result as offsetting the split segments
        let pOffset = p.offset(distance: 1)

        for (c1, c2) in zip(pOffset.curves, ql.offset(distance: 1) + qr.offset(distance: 1)) {
            XCTAssert(c1 == c2)
        }
    }

    func testRect() {
        let r = Rect(x: 10, y: 11, width: 12, height: 13)
        let encoder = JSONEncoder()
        let data = try! encoder.encode(r)
        let s = String(data: data, encoding: .utf8)!
        print(s)
    }

    private let p1 = Point(x: 0.0, y: 1.0)
    private let p2 = Point(x: 2.0, y: 1.0)
    private let p3 = Point(x: 2.5, y: 0.5)
    private let p4 = Point(x: 2.0, y: 0.0)
    private let p5 = Point(x: 0.0, y: 0.0)
    private let p6 = Point(x: -0.5, y: 0.25)
    private let p7 = Point(x: -0.5, y: 0.75)
    private let p8 = Point(x: 0.0, y: 1.0)

    func testEquatable() {
        let l1 = Line(p0: p1, p1: p2)
        let q1 = Quad(p0: p2, p1: p3, p2: p4)
        let l2 = Line(p0: p4, p1: p5)
        let c1 = Cubic(p0: p5, p1: p6, p2: p7, p3: p8)

        let subpath1 = Subpath(curves: [l1, q1, l2, c1])
        let subpath2 = Subpath(curves: [l1, q1, l2])
        let subpath3 = Subpath(curves: [l1, q1, l2, c1])

        var altC1 = c1
        altC1.p2.x = -0.25
        let subpath4 = Subpath(curves: [l1, q1, l2, altC1])

        XCTAssertNotEqual(subpath1, subpath2) // subpath2 is missing 4th path element, so not equal
        XCTAssertEqual(subpath1, subpath3)    // same path elements means equal
        XCTAssertNotEqual(subpath1, subpath4) // subpath4 has an element with a modified path
    }
}
