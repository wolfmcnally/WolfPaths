//
//  Subpath.swift
//  WolfPaths
//
//  Created by Wolf McNally on 11/9/18.
//

import WolfGeometry

/// A Subpath is a from point, a sequence of Segments, and a flag as to whether the path is closed.
public final class Subpath {
    public let from: Point
    public let segments: [Segment]
    public let isClosed: Bool

    lazy var boundingVolumeNode = BoundingVolumeNode(objects: curves)

    public init(from: Point = .zero, segments: [Segment] = [], isClosed: Bool = false) {
        self.from = from
        self.segments = segments
        self.isClosed = isClosed
    }

    public convenience init(from: Point, segment: Segment, isClosed: Bool = false) {
        self.init(from: from, segments: [segment], isClosed: isClosed)
    }

    public convenience init(curve: Curve, isClosed: Bool = false) {
        self.init(from: curve.from, segment: curve.segment, isClosed: isClosed)
    }

    public convenience init(curves: [Curve], isClosed: Bool = false) {
        guard !curves.isEmpty else {
            self.init(isClosed: isClosed)
            return
        }

        self.init(from: curves[0].from, segments: curves.map({ $0.segment }), isClosed: isClosed)
    }

    public func cleanup() -> Subpath {
        guard !isEmpty else { return self }
        guard isClosed else { return self }

        // If the subpath is closed and the last segment is a line back to the from point, then
        // the last element is redundant, so remove it
        switch segments.last {
        case .line(let to)?:
            if to == from {
                return Subpath(from: from, segments: Array(segments.dropLast()), isClosed: isClosed)
            }
        default:
            return self
        }

        return self
    }

    public var isEmpty: Bool {
        return segments.isEmpty
    }

    public var curves: [Curve] {
        var curPoint = from
        var result = [Curve]()
        for segment in segments {
            let curve = segment.curve(from: curPoint)
            result.append(curve)
            curPoint = curve.to
        }
        return result
    }

    public var length: Double {
        return curves.reduce(0.0) { $0 + $1.length }
    }

    public var boundingBox: BoundingBox {
        return boundingVolumeNode.boundingBox
    }

    public func offset(distance d: Double) -> Subpath {
        return Subpath(curves: curves.reduce([]) {
            $0 + $1.offset(distance: d)
        })
    }
}

extension Subpath: Equatable {
    public static func == (lhs: Subpath, rhs: Subpath) -> Bool {
        guard lhs.from == rhs.from else { return false }
        guard lhs.isClosed == rhs.isClosed else { return false }
        return lhs.segments == rhs.segments
    }
}
