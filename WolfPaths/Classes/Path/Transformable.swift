//
//  Transformable.swift
//  WolfPaths
//
//  Created by Wolf McNally on 11/19/18.
//

import WolfGeometry

public protocol Transformable {
    func transformed(using transform: Transform) -> Self
}
