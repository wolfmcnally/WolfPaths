//
//  Geometry.swift
//  WolfPaths
//
//  Created by Wolf McNally on 11/9/18.
//

import WolfGeometry

public let epsilon = 1.0e-8

func toString(_ point: Point) -> String {
    let numFormat = "%.6g"
    return String(format: "\(numFormat), \(numFormat)", arguments: [point.x, point.y])
}
