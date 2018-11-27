//
//  PathElement.swift
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

public enum PathElement {
    case move(to: CGPoint)
    case line(to: CGPoint)
    case quadCurve(to: CGPoint, control: CGPoint)
    case cubicCurve(to: CGPoint, control1: CGPoint, control2: CGPoint)
    case close
}

extension PathElement: CustomStringConvertible {
    private func string(for point: CGPoint) -> String {
        let numFormat = "%.6g"
        return String(format: "\(numFormat), \(numFormat)", arguments: [point.x, point.y])
    }

    public var description: String {
        switch self {
        case .move(let point):
            return "move(to: \(string(for: point)))"
        case .line(let point):
            return "line(to: \(string(for: point)))"
        case .quadCurve(let toPoint, let control):
            return "quad(to: \(string(for: toPoint)), control: \(string(for: control)))"
        case .cubicCurve(let toPoint, let control1, let control2):
            return "cubic(to: \(string(for: toPoint)), control1: \(string(for: control1)), control2: \(string(for: control2)))"
        case .close:
            return "close"
        }
    }
}

extension PathElement: Equatable {
    public static func == (lhs: PathElement, rhs: PathElement) -> Bool {
        switch lhs {
        case .move(let toPoint):
            switch rhs {
            case .move(let toPoint2):
                return toPoint == toPoint2
            default:
                return false
            }
        case .line(let toPoint):
            switch rhs {
            case .line(let toPoint2):
                return toPoint == toPoint2
            default:
                return false
            }
        case .quadCurve(let toPoint, let controlPoint):
            switch rhs {
            case .quadCurve(let toPoint2, let controlPoint2):
                return toPoint == toPoint2 && controlPoint == controlPoint2
            default:
                return false
            }
        case .cubicCurve(let toPoint, let control1Point, let control2Point):
            switch rhs {
            case .cubicCurve(let toPoint2, let control1Point2, let control2Point2):
                return toPoint == toPoint2 && control1Point == control1Point2 && control2Point == control2Point2
            default:
                return false
            }
        case .close:
            switch rhs {
            case .close:
                return true
            default:
                return false
            }
        }
    }
}
