//
//  Path.swift
//  WolfPaths
//
//  Created by Wolf McNally on 11/9/18.
//

import WolfGeometry

/// A Path is a sequence of Subpaths.
public struct Path {
    public var subpaths: [Subpath]

    public init(_ subpaths: [Subpath]) {
        self.subpaths = subpaths
    }

    public init(_ subpath: Subpath) {
        self.subpaths = [subpath]
    }

    public init(from: Point, segment: Segment, isClosed: Bool = false) {
        self.init(Subpath(from: from, segment: segment, isClosed: isClosed))
    }
}

extension Path {
    public init(cgPath: CGPath) {
        var subpaths: [Subpath] = []
        var from: Point!
        var segments = [Segment]()

        func resetSubpath() {
            from = nil
            segments.removeAll()
        }

        var hasCurrentSubpath: Bool {
            return from != nil
        }

        func beginSubpath(at p: Point) {
            if hasCurrentSubpath {
                subpaths.append(Subpath(from: from, segments: segments, isClosed: false))
                resetSubpath()
            }
            from = p
        }

        func continueSubpath(with segment: Segment) {
            if !hasCurrentSubpath {
                from = .zero
            }
            segments.append(segment)
        }

        func endSubpath(isClosed: Bool) {
            if hasCurrentSubpath {
                subpaths.append(Subpath(from: from, segments: segments, isClosed: isClosed))
                resetSubpath()
            }
        }

        cgPath.apply { pathElement in
            switch pathElement {
            case .move(to: let p):
                beginSubpath(at: Point(p))
            case .line(to: let p1):
                continueSubpath(with: .line(p1: Point(p1)))
            case .quadCurve(to: let p2, via: let p1):
                continueSubpath(with: .quad(p1: Point(p1), p2: Point(p2)))
            case .cubicCurve(to: let p3, v1: let p1, v2: let p2):
                continueSubpath(with: .cubic(p1: Point(p1), p2: Point(p2), p3: Point(p3)))
            case .close:
                endSubpath(isClosed: true)
            }
        }
        endSubpath(isClosed: false)
        self.subpaths = subpaths
    }

    public var cgPath: CGPath {
        let resultPath = CGMutablePath()
        for subpath in subpaths {
            resultPath.move(to: CGPoint(subpath.from))
            for segment in subpath.segments {
                switch segment {
                case let .line(p1: p1):
                    resultPath.addLine(to: CGPoint(p1))
                case let .quad(p1: p1, p2: p2):
                    resultPath.addQuadCurve(to: CGPoint(p2), control: CGPoint(p1))
                case let .cubic(p1: p1, p2: p2, p3: p3):
                    resultPath.addCurve(to: CGPoint(p3), control1: CGPoint(p1), control2: CGPoint(p2))
                }
            }
            if subpath.isClosed {
                resultPath.closeSubpath()
            }
        }
        return resultPath.copy()!
    }
}

extension Path: Equatable {
    public static func == (lhs: Path, rhs: Path) -> Bool {
        return lhs.subpaths == rhs.subpaths
    }
}

// MARK: - Free Functions

public func toPath(_ cgPath: CGPath) -> Path {
    return Path(cgPath: cgPath)
}

public func toCGPath(_ path: Path) -> CGPath {
    return path.cgPath
}
