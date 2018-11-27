//
//  Terminus.swift
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

import BezierKit
import WolfGeometry

public struct Terminus {
    let point: CGPoint
    let angle: CGFloat
}

extension CGPath {
    public var tailTerminus: Terminus {
        let selfPath = BezierKit.Path(cgPath: self)
        let point: CGPoint
        let angle: CGFloat
        if let firstSubpath = selfPath.subpaths.first, let firstCurve = firstSubpath.curves.first {
            point = firstCurve.compute(0)
            angle = firstCurve.derivative(0).angle
        } else {
            point = .zero
            angle = 0
        }
        return Terminus(point: point, angle: angle)
    }

    public var headTerminus: Terminus {
        let selfPath = BezierKit.Path(cgPath: self)
        let point: CGPoint
        let angle: CGFloat
        if let firstSubpath = selfPath.subpaths.first, let firstCurve = firstSubpath.curves.first {
            point = firstCurve.compute(1)
            angle = firstCurve.derivative(1).angle + .pi
        } else {
            point = .zero
            angle = 0
        }
        return Terminus(point: point, angle: angle)
    }
}
