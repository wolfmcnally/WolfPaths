//
//  CGPathApply.swift
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

public typealias PathElementBlock = (PathElement) -> Void

private typealias PathElementPointerBlock = @convention(block) (UnsafePointer<CGPathElement>) -> Void

private func myPathApply(_ path: CGPath!, block: @escaping @convention(block) (UnsafePointer<CGPathElement>) -> Void) {
    let callback: @convention(c) (UnsafeMutableRawPointer, UnsafePointer<CGPathElement>) -> Void = { (info, element) in
        let block = unsafeBitCast(info, to: PathElementPointerBlock.self)
        block(element)
    }

    path.apply(info: unsafeBitCast(block, to: UnsafeMutableRawPointer.self), function: unsafeBitCast(callback, to: CGPathApplierFunction.self))
}

extension CGPath {
    func forEachElement(_ fn: @escaping (PathElement) -> Void) {
        myPathApply(self) { element in
            let points = element.pointee.points
            switch (element.pointee.type) {

            case .moveToPoint:
                fn(.move(to: points[0]))

            case .addLineToPoint:
                fn(.line(to: points[0]))

            case .addQuadCurveToPoint:
                fn(.quadCurve(to: points[1], control: points[0]))

            case .addCurveToPoint:
                fn(.cubicCurve(to: points[2], control1: points[0], control2: points[1]))

            case .closeSubpath:
                fn(.close)
            }
        }
    }
}
