//
//  Segment.swift
//  WolfPaths
//
//  Created by Wolf McNally on 11/6/18.
//

import WolfGeometry
import WolfPipe

/// A Segment is relative to an implied current point, and is either a straight line, a quadratic curve
/// (one control point) or a cubic curve (two control points).
public enum Segment {
    case line(p1: Point)
    case quad(p1: Point, p2: Point)
    case cubic(p1: Point, p2: Point, p3: Point)
}

extension Segment: CustomStringConvertible {
    public var description: String {
        switch self {
        case .line(let p1):
            return "line(p1: \(p1 |> toString)))"
        case .quad(let p1, let p2):
            return "quad(p1: \(p1 |> toString), p2: \(p2 |> toString))"
        case .cubic(let p1, let p2, let p3):
            return "cubic(to: \(p1 |> toString), control1: \(p2 |> toString), control2: \(p3 |> toString))"
        }
    }

    public func curve(from: Point) -> Curve {
        switch self {
        case .line(let p1):
            return Line(p0: from, p1: p1);
        case .quad(let p1, let p2):
            return Quad(p0: from, p1: p1, p2: p2)
        case .cubic(let p1, let p2, let p3):
            return Cubic(p0: from, p1: p1, p2: p2, p3: p3)
        }
    }
}

extension Segment: Equatable {
    public static func == (lhs: Segment, rhs: Segment) -> Bool {
        switch lhs {
        case .line(p1: let aTo):
            switch rhs {
            case .line(p1: let bTo):
                return aTo == bTo
            default:
                return false
            }
        case .quad(p1: let ap1, p2: let ap2):
            switch rhs {
            case .quad(p1: let bp1, p2: let bp2):
                return ap1 == bp1 && ap2 == bp2
            default:
                return false
            }
        case .cubic(p1: let ap1, p2: let ap2, p3: let ap3):
            switch rhs {
            case .cubic(p1: let bp1, p2: let bp2, p3: let bp3):
                return ap1 == bp1 && ap2 == bp2 && ap3 == bp3
            default:
                return false
            }
        }
    }
}
