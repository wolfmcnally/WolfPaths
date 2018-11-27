//
//  StrokeOperations.swift
//  WolfPaths
//
//  Created by Wolf McNally on 10/18/18.
//

import CoreGraphics

/// If the first element is `.move` and the last element is `.close`,
/// and next-to-last element is a `.line` with the same to-point
/// as the `.move` at the start, rewrite the path as an equivalent closed path
/// omitting the next-to-last `.line` element.
func simplifyClosedPath(_ elements: [PathElement]) -> [PathElement] {
    guard elements.count >= 3 else {
        return elements
    }

    let startPoint: CGPoint
    switch elements.first! {
    case .move(let p):
        startPoint = p
    default:
        return elements
    }

    switch elements.last! {
    case .close:
        break
    default:
        return elements
    }

    let endPoint: CGPoint
    switch elements[elements.count - 2] {
    case .line(let p):
        endPoint = p
    default:
        return elements
    }

    guard startPoint == endPoint else {
        return elements
    }

    var e = Array(elements.dropLast(2))
    e.append(.close)
    return e
}

extension CGPath {
    public func stroked(width: CGFloat, lineCap: CGLineCap = .butt, lineJoin: CGLineJoin = .bevel, miterLimit: CGFloat = 0) -> CGPath {
        let path = copy(strokingWithWidth: width, lineCap: lineCap, lineJoin: lineJoin, miterLimit: miterLimit)
        guard let elements = path.subpaths.first else {
            return path
        }
        let simplifiedElements = simplifyClosedPath(elements)
        return CGPath.makeWithElements(simplifiedElements)
    }
}
