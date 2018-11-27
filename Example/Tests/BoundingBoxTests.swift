//
//  BoundingBoxTests.swift
//  WolfPaths_Tests
//
//  Created by Wolf McNally on 11/18/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
@testable import WolfPaths
import WolfGeometry

class BoundingBoxTests: XCTestCase {
    let pointNan        = Point(x: Double.nan, y: Double.nan)
    let zeroBox         = BoundingBox(p1: .zero, p2: .zero)
    let infiniteBox     = BoundingBox(p1: -.infinite, p2: .infinite)
    let sampleBox       = BoundingBox(p1: Point(x: -1.0, y: -2.0), p2: Point(x: 3.0, y: -1.0))

    func testEmpty() {
        let nanBox = BoundingBox(p1: pointNan, p2: pointNan)
        let e = BoundingBox.empty
        XCTAssert(e.size == .zero)
        XCTAssertTrue(e == BoundingBox.empty)

        XCTAssertFalse(e.overlaps(e))
        XCTAssertFalse(e.overlaps(zeroBox))
        XCTAssertFalse(e.overlaps(sampleBox))
        XCTAssertFalse(e.overlaps(infiniteBox))
        XCTAssertFalse(e.overlaps(nanBox))
    }

    func testLowerAndUpperBounds() {
        let box = BoundingBox(p1: Point(x: 2.0, y: 3.0), p2: Point(x: 3.0, y: 5.0))

        let p1 = Point(x: 2.0, y: 4.0)
        let p2 = Point(x: 2.5, y: 3.5)
        let p3 = Point(x: 1.0, y: 4.0)
        let p4 = Point(x: 3.0, y: 7.0)
        let p5 = Point(x: -1.0, y: -1.0)

        XCTAssertEqual(box.lowerBoundOfDistance(to: p1), 0.0)    // on the boundary
        XCTAssertEqual(box.lowerBoundOfDistance(to: p2), 0.0)    // fully inside
        XCTAssertEqual(box.lowerBoundOfDistance(to: p3), 1.0)    // outside (straight horizontally)
        XCTAssertEqual(box.lowerBoundOfDistance(to: p4), 2.0)    // outside (straight vertically)
        XCTAssertEqual(box.lowerBoundOfDistance(to: p5), 5.0)  // outside (nearest bottom left corner)

        XCTAssertEqual(box.upperBoundOfDistance(to: p1), sqrt(2.0))
        XCTAssertEqual(box.upperBoundOfDistance(to: p2), sqrt(2.5))
        XCTAssertEqual(box.upperBoundOfDistance(to: p3), sqrt(5))
        XCTAssertEqual(box.upperBoundOfDistance(to: p4), sqrt(17.0))
        XCTAssertEqual(box.upperBoundOfDistance(to: p5), sqrt(52.0))
    }

    func testArea() {
        let box = BoundingBox(p1: Point(x: 2.0, y: 3.0), p2: Point(x: 3.0, y: 5.0))
        XCTAssertEqual(box.area, 2.0)
        let emptyBox = BoundingBox.empty
        XCTAssertEqual(emptyBox.area, 0.0)
    }

    func testOverlaps() {
        let box1 = BoundingBox(p1: Point(x: 2.0, y: 3.0), p2: Point(x: 3.0, y: 5.0))
        let box2 = BoundingBox(p1: Point(x: 2.5, y: 6.0), p2: Point(x: 3.0, y: 8.0))
        let box3 = BoundingBox(p1: Point(x: 2.5, y: 4.0), p2: Point(x: 3.0, y: 8.0))
        XCTAssertFalse(box1.overlaps(box2))
        XCTAssertTrue(box1.overlaps(box3))
        XCTAssertFalse(box1.overlaps(BoundingBox.empty))
    }

    func testUnionEmpty1() {
        let empty1 = BoundingBox.empty
        let empty2 = BoundingBox.empty
        XCTAssertEqual(empty1.union(empty2), BoundingBox.empty)
    }

    func testUnionEmpty2() {
        let empty = BoundingBox.empty
        let box = BoundingBox(p1: Point(x: 2.0, y: 3.0), p2: Point(x: 3.0, y: 5.0))
        XCTAssertEqual(empty.union(box), box)
    }

    func testUnion() {
        let box1 = BoundingBox(p1: Point(x: 2.0, y: 3.0), p2: Point(x: 3.0, y: 5.0))
        let box2 = BoundingBox(p1: Point(x: 2.5, y: 6.0), p2: Point(x: 3.0, y: 8.0))
        XCTAssertEqual(box1.union(box2), BoundingBox(p1: Point(x: 2.0, y: 3.0), p2: Point(x: 3.0, y: 8.0)))
    }

    func testRect() {
        // test a standard box
        let box1 = BoundingBox(p1: Point(x: 2.0, y: 3.0), p2: Point(x: 3.0, y: 5.0))
        XCTAssertEqual(box1.rect, Rect(origin: Point(x: 2.0, y: 3.0), size: Size(width: 1.0, height: 2.0)))
        // test the empty box
        XCTAssertEqual(BoundingBox.empty.rect, Rect.null)
    }

    func testInitFirstSecond() {
        let box1 = BoundingBox(p1: Point(x: 2.0, y: 3.0), p2: Point(x: 3.0, y: 5.0))
        let box2 = BoundingBox(p1: Point(x: 1.0, y: 1.0), p2: Point(x: 2.0, y: 2.0))
        let result = BoundingBox(first: box1, second: box2)
        XCTAssertEqual(result, BoundingBox(p1: Point(x: 1.0, y: 1.0), p2: Point(x: 3.0, y: 5.0)))
    }
}
