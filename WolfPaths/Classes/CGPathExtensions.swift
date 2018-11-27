//
//  CGPathExtensions.swift
//  WolfPaths
//
//  Created by Wolf McNally on 10/18/18.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import CoreGraphics
import WolfGeometry

extension CGPath {
    public static var empty: CGPath = {
        let path = CGMutablePath()
        return path.copy()!
    }()

    public static func makeWithLine(from p1: CGPoint, to p2: CGPoint) -> CGPath {
        let path = CGMutablePath()
        path.move(to: p1)
        path.addLine(to: p2)
        return path.copy()!
    }

    public static func makeWithLine(_ line: LineSegment) -> CGPath {
        return makeWithLine(from: line.p0, to: line.p1)
    }

    public var reversed: CGPath {
        let p = OSBezierPath(cgPath: self)
        return p.reversing().cgPath
    }
}

extension CGPath: CustomDebugStringConvertible {
    public var debugDescription: String {
        var pathElements = [String]()

        func string(for point: CGPoint) -> String {
            let numFormat = "%.6g"
            return String(format: "\(numFormat), \(numFormat)", arguments: [point.x, point.y])
        }

        forEachElement { element in
            pathElements.append(element.description)
        }

        return pathElements.joined(separator: " ")
    }
}
