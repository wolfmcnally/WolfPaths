//
//  Subcurve.swift
//  WolfPaths
//
//  Created by Wolf McNally on 11/11/18.
//

import WolfGeometry
import WolfNumerics

public struct Subcurve<C> where C: Curve {
    public let t1, t2: Double
    public let curve: C

    init(curve: C) {
        self.t1 = 0.0
        self.t2 = 1.0
        self.curve = curve
    }

    init(t1: Double, t2: Double, curve: C) {
        self.t1 = t1
        self.t2 = t2
        self.curve = curve
    }

    func split(from t1: Double, to t2: Double) -> Subcurve<C> {
        let curve: C = self.curve.split(from: t1, to: t2)
        return Subcurve<C>(t1: t1.lerpedFromFrac(to: self.t1 .. self.t2),
                           t2: t2.lerpedFromFrac(to: self.t1 .. self.t2),
                           curve: curve)
    }

    func split(at t: Double) -> (left: Subcurve<C>, right: Subcurve<C>) {
        let (left, right) = curve.split(at: t)
        let t1 = self.t1
        let t2 = self.t2
        let subcurveLeft = Subcurve<C>(t1: (0.0).lerpedFromFrac(to: t1 .. t2),
                                       t2: t.lerpedFromFrac(to: t1 .. t2),
                                       curve: left)
        let subcurveRight = Subcurve<C>(t1: t.lerpedFromFrac(to: t1 .. t2),
                                        t2: (1.0).lerpedFromFrac(to: t1 .. t2),
                                        curve: right)
        return (left: subcurveLeft, right: subcurveRight)
    }
    // TODO: equatable support
}
