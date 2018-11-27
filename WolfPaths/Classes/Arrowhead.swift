//
//  Arrowhead.swift
//  WolfGraph
//
//  Created by Wolf McNally on 10/15/18.
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
import VectorBoolean

public struct Arrowhead {
    public let blanking: CGPath?
    public let symbol: CGPath?

    private func positionPath(_ path: CGPath?, to point: CGPoint, angle: CGFloat, scale: CGFloat) -> CGPath? {
        guard let path = path else { return nil }
        let translation = CGAffineTransform(translation: CGVector(point: point))
        let rotation = CGAffineTransform(rotationAngle: angle)
        let scaling = CGAffineTransform(scaleX: scale, y: scale)
        var transform = scaling.concatenating(rotation).concatenating(translation)
        let transformed = path.copy(using: &transform)!
        return transformed
    }

    func positioned(at terminus: Terminus, scale: CGFloat) -> Arrowhead {
        let newBlanking = positionPath(blanking, to: terminus.point, angle: terminus.angle, scale: scale)
        let newSymbol = positionPath(symbol, to: terminus.point, angle: terminus.angle, scale: scale)
        return Arrowhead(blanking: newBlanking, symbol: newSymbol)
    }
}

extension Arrowhead {
    public static let none = Arrowhead(blanking: nil, symbol: nil)
    public static let simple = Arrowhead(blanking: makeBlankingPath(width: 2.5), symbol: simplePath)
    public static let triangle = Arrowhead(blanking: makeBlankingPath(), symbol: trianglePath)
    public static let square = Arrowhead(blanking: makeBlankingPath(width: squareWidth), symbol: squarePath)
    public static let circle = Arrowhead(blanking: makeBlankingPath(width: squareWidth), symbol: circlePath)
    public static let openCircle = Arrowhead(blanking: makeBlankingPath(width: squareWidth), symbol: openCirclePath)
    public static let openSquare = Arrowhead(blanking: makeBlankingPath(width: squareWidth), symbol: openSquarePath)

    private static let minX: CGFloat = 0
    private static let maxWidth: CGFloat = 9
    private static let halfHeight: CGFloat = 3
    private static let squareWidth: CGFloat = halfHeight * 2

    //
    // 0       maxX
    // |        |
    // |
    // |     ---|      minY
    //    ---   |
    // ---      |----- 0
    //    ---   |
    //       ---|      -minY
    //

    private static var emptyPath: CGPath = {
        return CGMutablePath().copy()!
    }()

    private static func makeBlankingPath(width: CGFloat = maxWidth) -> CGPath {
        let path = CGMutablePath()

        let slop: CGFloat = 2
        let y = halfHeight + slop

        path.move(to: CGPoint(x: minX - slop, y: -y))
        path.addLine(to: CGPoint(x: width - 1.001, y: -y))
        path.addLine(to: CGPoint(x: width - 1.001, y: y))
        path.addLine(to: CGPoint(x: minX - slop, y: y))
        path.closeSubpath()

        return path.copy()!
    }

    private static var simplePath: CGPath = {
        let path = CGMutablePath()
        let offset: CGFloat = 1.5
        path.move(to: CGPoint(x: maxWidth + offset, y: halfHeight))
        path.addLine(to: CGPoint(x: offset, y: 0))
        path.addLine(to: CGPoint(x: maxWidth + offset, y: -halfHeight))
        return path.copy(strokingWithWidth: 1, lineCap: .butt, lineJoin: .miter, miterLimit: 10)
    }()

    private static var trianglePath: CGPath = {
        let path = CGMutablePath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: maxWidth, y: halfHeight))
        path.addLine(to: CGPoint(x: maxWidth, y: -halfHeight))
        path.closeSubpath()
        return path.copy()!
    }()

    private static func makeSquarePath(center: CGPoint, radius: CGFloat) -> CGPath {
        let size = CGSize(width: radius * 2, height: radius * 2)
        let rect = CGRect(center: center, size: size)
        return CGPath(rect: rect, transform: nil)
    }

    private static var squarePath: CGPath = {
        let center = CGPoint(x: halfHeight, y: 0)
        return makeSquarePath(center: center, radius: halfHeight)
    }()

    private static var openSquarePath: CGPath = {
        let center = CGPoint(x: halfHeight, y: 0)
        let outerPath = makeSquarePath(center: center, radius: halfHeight)
        let innerPath = makeSquarePath(center: center, radius: halfHeight - 1).reversed
        let path = CGMutablePath()
        path.addPath(outerPath)
        path.addPath(innerPath)
        return path.copy()!
    }()

    private static func makeCirclePath(center: CGPoint, radius: CGFloat) -> CGPath {
        let size = CGSize(width: radius * 2, height: radius * 2)
        let rect = CGRect(center: center, size: size)
        return CGPath(ellipseIn: rect, transform: nil)
    }

    private static var circlePath: CGPath = {
        let center = CGPoint(x: halfHeight, y: 0)
        return makeCirclePath(center: center, radius: halfHeight)
    }()

    private static var openCirclePath: CGPath = {
        let center = CGPoint(x: halfHeight, y: 0)
        let outerPath = makeCirclePath(center: center, radius: halfHeight)
        let innerPath = makeCirclePath(center: center, radius: halfHeight - 1).reversed
        let path = CGMutablePath()
        path.addPath(outerPath)
        path.addPath(innerPath)
        return path.copy()!
    }()
}

extension CGPath {
    public func composedWith(arrowhead: Arrowhead, at terminus: Terminus, scale: CGFloat) -> CGPath {
        let arrowhead = arrowhead.positioned(at: terminus, scale: scale)
        var path = self
        if let blanking = arrowhead.blanking {
            path = path.difference(blanking)
        }
        if let symbol = arrowhead.symbol {
            path = path.union(symbol)
        }
        return path
    }
}
