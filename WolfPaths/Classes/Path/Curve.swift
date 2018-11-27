//
//  Curve.swift
//  WolfPaths
//
//  Created by Wolf McNally on 11/9/18.
//

import WolfGeometry
import WolfNumerics

public typealias DistanceFunction = (_ v: Double) -> Double

/// A Curve is a function from a "from" point to a "to" point.
public protocol Curve: Bounded, Transformable, Reversible {
    init(points: [Point])
    
    var from: Point { get }
    var to: Point { get }
    var order: Int { get }

    var points: [Point] { get }
    var segment: Segment { get }
    var isSimple: Bool { get }
    
    /// Returns the point at a fraction along the curve
    func point(at t: Frac) -> Point

    /// Returnes the derivative (vector) at a fraction along the curve
    func vector(at t: Frac) -> Vector

    /// Returns the length of the curve
    var length: Double { get }

    func split(from t1: Double, to t2: Double) -> Self
    func split(at t: Double) -> (left: Self, right: Self)

    var extrema: (xyz: [[Double]], values: [Double]) { get }
    func generateLookupTable(withSteps steps: Int) -> [Point]
    func intersects(curve: Curve, threshold: Double) -> [Intersection]
}

public func == (lhs: Curve, rhs: Curve) -> Bool {
    return lhs.points == rhs.points
}

extension Curve {
    private var isLinear: Bool {
        var a = Utils.align(points, p1: from, p2: to)
        for i in 0 ..< a.count {
            // TODO: investigate horrible magic number usage
            if abs(a[i].y) > 0.0001 {
                return false
            }
        }
        return true
    }

    /// Calculates the length of this Bezier curve. Length is calculated using numerical approximation, specifically the Legendre-Gauss quadrature algorithm.
    public var length: Double {
        return Utils.length { self.vector(at: $0) }
    }

    public func normal(at t: Double) -> Vector {
        let d = vector(at: t).normalized
        return Vector(dx: -d.dy, dy: d.dx)
    }

    public func hull(_ t: Double) -> [Point] {
        return Utils.hull(points, t)
    }

    public func generateLookupTable(withSteps steps: Int = 100) -> [Point] {
        assert(steps >= 0)
        var table: [Point] = []
        table.reserveCapacity(steps + 1)
        for i in 0 ... steps {
            let t = Double(i) / Double(steps)
            table.append(point(at: t))
        }
        return table
    }
}

extension Curve {
    public var extrema: (xyz: [[Double]], values: [Double]) {
        var dpoints: [[Point]] {
            var ret: [[Point]] = []
            var p = points
            ret.reserveCapacity(p.count - 1)
            for d in (2 ... p.count).reversed() {
                let c = d - 1
                var list: [Point] = []
                list.reserveCapacity(c)
                for j in 0 ..< c {
                    let dpt = Point(p[j + 1] - p[j]) * Double(c)
                    list.append(dpt)
                }
                ret.append(list)
                p = list
            }
            return ret
        }

        // computes the extrema for each dimension
        func internalExtrema(includeInflection: Bool) -> [[Double]] {
            var xyz: [[Double]] = []
            xyz.reserveCapacity(Point.dimensions)
            // TODO: this code can be made a lot faster through inlining the droots computation such that allocations need not occur
            for d in 0 ..< Point.dimensions {
                var p: [Double] = dpoints[0].map { $0[d] }
                xyz.append(Utils.droots(p))
                if includeInflection && order >= 3 {
                    p = dpoints[1].map { $0[d] }
                    xyz[d] += Utils.droots(p)
                }
                xyz[d] = xyz[d].filter({$0 >= 0 && $0 <= 1}).sorted()
            }
            return xyz
        }


        let xyz = internalExtrema(includeInflection: true)
        var roots = xyz.flatMap{$0}.sorted() // the roots for each dimension, flattened and sorted
        var values: [Double] = []
        if roots.count > 0 {
            values.reserveCapacity(roots.count)
            var lastInserted: Double = -Double.infinity
            for i in 0..<roots.count { // loop ensures (pre-sorted) roots are unique when added to values
                let v = roots[i]
                if v > lastInserted {
                    values.append(v)
                    lastInserted = v
                }
            }
        }
        return (xyz: xyz, values: values)
    }
}

extension Curve {
    /// Reduces a curve to a collection of "simple" subcurves, where a simpleness is defined as having all control points on the same side of the baseline (cubics having the additional constraint that the control-to-end-point lines may not cross), and an angle between the end point normals no greater than 60 degrees.
    /// The main reason this function exists is to make it possible to scale curves. As mentioned in the offset function, curves cannot be offset without cheating, and the cheating is implemented in this function. The array of simple curves that this function yields can safely be scaled.
    public func reduce() -> [Subcurve<Self>] {
        // todo: handle degenerate case of Cubic with all zero points better!

        let step: Double = 0.01
        var extrema: [Double] = self.extrema.values
        extrema = extrema.filter {
            if $0 < step {
                return false // filter out extreme points very close to 0.0
            }
            else if (1.0 - $0) < step {
                return false // filter out extreme points very close to 1.0
            }
            return true
        }
        // aritifically add 0.0 and 1.0 to our extreme points
        extrema.insert(0.0, at: 0)
        extrema.append(1.0)

        // first pass: split on extrema
        var pass1: [Subcurve<Self>] = []
        pass1.reserveCapacity(extrema.count-1)
        for i in 0..<extrema.count-1 {
            let t1 = extrema[i]
            let t2 = extrema[i+1]
            let curve = split(from: t1, to: t2)
            pass1.append(Subcurve(t1: t1, t2: t2, curve: curve))
        }

        func bisectionMethod(min: Double, max: Double, tolerance: Double, callback: (_ value: Double) -> Bool) -> Double {
            var lb = min // lower bound (callback(x <= lb) should return true
            var ub = max // upper bound (callback(x >= ub) should return false
            while (ub - lb) > tolerance {
                let val = 0.5 * (lb + ub)
                if callback(val) {
                    lb = val
                }
                else {
                    ub = val
                }
            }
            return lb
        }

        // second pass: further reduce these segments to simple segments
        var pass2: [Subcurve<Self>] = []
        pass2.reserveCapacity(pass1.count)
        pass1.forEach({(p1: Subcurve<Self>) in
            var t1: Double = 0.0
            while t1 < 1.0 {
                let fullSegment = p1.split(from: t1, to: 1.0)
                if (1.0 - t1) <= step || fullSegment.curve.isSimple {
                    // if the step is small or the full segment is simple, use it
                    pass2.append(fullSegment)
                    t1 = 1.0
                }
                else {
                    // otherwise use bisection method to find a suitable step size
                    let t2 = bisectionMethod(min: t1 + step, max: 1.0, tolerance: step) {
                        return p1.split(from: t1, to: $0).curve.isSimple
                    }
                    let partialSegment = p1.split(from: t1, to: t2)
                    pass2.append(partialSegment)
                    t1 = t2
                }
            }
        })
        return pass2
    }
}

extension Curve {
    public func intersects(line: Line) -> [Intersection] {
        if let l = self as? Line {
            return l.intersects(line: line)
        }
        let lineDirection = (line.p1 - line.p0).normalized
        let lineLength = (line.p1 - line.p0).magnitude
        return Utils.roots(points: points, line: line).map({(t: Double) -> Intersection in
            let p = point(at: t) - line.p0
            let t2 = dot(p, lineDirection) / lineLength
            return Intersection(t1: t, t2: t2)
        }).filter({$0.t2 >= 0.0 && $0.t2 <= 1.0}).sorted()
    }

    public func selfIntersections(threshold: Double = defaultIntersectionThreshold) -> [Intersection] {
        let reduced = reduce()
        // "simple" curves cannot intersect with their direct
        // neighbour, so for each segment X we check whether
        // it intersects [0:x-2][x+2:last].
        let len = reduced.count - 2
        var results: [Intersection] = []
        if len > 0 {
            for i in 0 ..< len {
                let left = [reduced[i]]
                let right = Array(reduced.suffix(from: i + 2))
                let result = Self.internalCurvesIntersect(c1: left, c2: right, threshold: threshold)
                results += result
            }
        }
        return results
    }

    public func intersects(curve: Curve, threshold: Double = defaultIntersectionThreshold) -> [Intersection] {
//        precondition(curve !== self, "unsupported: use intersects() method for self-intersection")

        let s = Subcurve<Self>(curve: self)

        if let c = curve as? Cubic {
            return Self.internalCurvesIntersect(c1: [s], c2: [Subcurve(curve: c)], threshold: threshold)
        } else if let q = curve as? Quad {
            return Self.internalCurvesIntersect(c1: [s], c2: [Subcurve(curve: q)], threshold: threshold)
        } else if let l = curve as? Line {
            if let m = self as? Line {
                // TODO: clean up this logic, the problem is that `intersects` is statically dispatched
                // otherwise we'll end up calling into the curve-line intersection method and it'll crash (awful)
                return m.intersects(line: l)
            } else {
                return intersects(line: l)
            }
        } else {
            fatalError("unsupported")
        }
    }

    private static func internalCurvesIntersect<C1, C2>(c1: [Subcurve<C1>], c2: [Subcurve<C2>], threshold: Double) -> [Intersection] {
        var intersections: [Intersection] = []
        for l in c1 {
            for r in c2 {
                Utils.pairiteration(l, r, &intersections, threshold)
            }
        }
        // TODO: you should probably have a unit test that ensures de-duping actually works

        // sort the results by t1 (and by t2 if t1 equal)
        intersections = intersections.sorted(by: <)
        // de-dupe the sorted array
        intersections = intersections.reduce(Array<Intersection>(), {(intersection: [Intersection], next: Intersection) in
            return (intersection.count == 0 || intersection[intersection.count-1] != next) ? intersection + [next] : intersection
        })

        return intersections
    }
}

extension Curve {

    public func outline(distance d1: Double) -> Subpath {
        return internalOutline(d1: d1, d2: d1, d3: 0.0, d4: 0.0, graduated: false)
    }

    public func outline(distanceAlongNormal d1: Double, distanceOppositeNormal d2: Double) -> Subpath {
        return internalOutline(d1: d1, d2: d2, d3: 0.0, d4: 0.0, graduated: false)
    }

    public func outline(distanceAlongNormalStart d1: Double,
                        distanceOppositeNormalStart d2: Double,
                        distanceAlongNormalEnd d3: Double,
                        distanceOppositeNormalEnd d4: Double) -> Subpath {
        return internalOutline(d1: d1, d2: d2, d3: d3, d4: d4, graduated: true)
    }

    private func internalOutline(d1: Double, d2: Double, d3: Double, d4: Double, graduated: Bool) -> Subpath {

        let reduced = reduce()
        let len = reduced.count
        var fcurves: [Curve] = []
        var bcurves: [Curve] = []
        //        var p
        let tlen = length

        let linearDistanceFunction = {(_ s: Double, _ e: Double, _ tlen: Double, _ alen: Double, _ slen: Double) -> DistanceFunction in
            return { (_ v: Double) -> Double in
                let f1 = alen / tlen
                let f2 = (alen+slen) / tlen
                let d = e-s
                return v.lerpedFromFrac(to: s + f1 * d .. s + f2 * d)
            }
        }

        // form curve oulines
        var alen = 0.0

        for segment in reduced {
            let curve = segment.curve
            let slen = curve.length
            if graduated {
                fcurves.append(curve.scale(distanceFunction: linearDistanceFunction( d1,  d3, tlen, alen, slen)  ))
                bcurves.append(curve.scale(distanceFunction: linearDistanceFunction(-d2, -d4, tlen, alen, slen)  ))
            } else {
                fcurves.append(curve.scale(distance: d1))
                bcurves.append(curve.scale(distance: -d2))
            }
            alen = alen + slen
        }

        // reverse the "return" outline
        bcurves = bcurves.map({(s: Curve) in
            return s.reversed()
        }).reversed()

        // form the endcaps as lines
        let fs = fcurves[0].points[0]
        let fe = fcurves[len-1].points[fcurves[len-1].points.count-1]
        let bs = bcurves[len-1].points[bcurves[len-1].points.count-1]
        let be = bcurves[0].points[0]
        let ls = Line(p0: bs, p1: fs)
        let le = Line(p0: fe, p1: be)
        let segments = [ls] + fcurves + [le] + bcurves
        //        let slen = segments.count

        return Subpath(curves: segments)
    }
}

extension Curve {
    /*
     Scales a curve with respect to the intersection between the end point normals. Note that this will only work if that point exists, which is only guaranteed for simple segments.
     */
    public func scale(distance d: Double) -> Self {
        return internalScale(distance: d, distanceFunction: nil)
    }

    private func scale(distanceFunction distanceFn: @escaping DistanceFunction) -> Self {
        return internalScale(distance: nil, distanceFunction: distanceFn)
    }

    //    private enum ScaleEnum {
    //        case d(Double)
    //        case distanceFunction(DistanceFunction)
    //    }

    private func internalScale(distance d: Double?, distanceFunction distanceFn: DistanceFunction?) -> Self {
        // TODO: this is a good candidate for enum, d is EITHER constant or a function
        precondition((d != nil && distanceFn == nil) || (d == nil && distanceFn != nil))

        let order = self.order

        //        if distanceFn != nil && self.order == 2 {
        //            // for quadratics we must raise to cubics prior to scaling
        //            //    return self.raise().scale(distance: nil, distanceFunction: distanceFn);
        //        }

        let r1 = (distanceFn != nil) ? distanceFn!(0) : d!
        let r2 = (distanceFn != nil) ? distanceFn!(1) : d!
        var v = [ internalOffset(t: 0, distance: 10), internalOffset(t: 1, distance: 10) ]
        // move all points by distance 'd' wrt the origin 'o'
        var points: [Point] = self.points
        var np: [Point] = [Point](repeating: .zero, count: order + 1)

        // move end points by fixed distance along normal.
        for t in [0,1] {
            let p: Point = points[t*order]
            np[t*order] = p + ((t != 0) ? r2 : r1) * v[t].n
        }

        if order < 2 {
            // for offsetting line segments, we are done
            return Self.init(points: np)
        }

        let o = Utils.lli4(v[0].p, v[0].c, v[1].p, v[1].c)

        if d != nil {
            // move control points to lie on the intersection of the offset
            // derivative vector, and the origin-through-control vector
            for t in [0,1] {
                if (order == 2) && (t != 0) {
                    break
                }
                let p = np[t*order] // either the first or last of np
                let dt = Double(t)
                let d = vector(at: dt)
                let p2 = p + d
                let o2 = (o != nil) ? o! : points[t+1] - normal(at: dt)
                np[t+1] = Utils.lli4(p, p2, o2, points[t+1])!
            }
        } else {
            var isClockwise: Bool {
                let points = self.points
                let angle = angleAtVertex(o: points[0], points[order], points[1])
                return angle > 0
            }
            for t in [0,1] {
                if (order == 2) && (t != 0) {
                    break
                }
                let p = points[t+1]
                let dt = Double(t)
                let ov = (o != nil) ? (p - o!).normalized : -normal(at: dt)
                var rc = distanceFn!(dt + 1) / Double(order)
                if !isClockwise {
                    rc = -rc
                }
                np[t+1] = p + rc * ov
            }
        }
        return Self.init(points: np)
    }
}

extension Curve {
    public func offset(distance d: Double) -> [Curve] {
        if isLinear {
            let n = normal(at: 0)
            let coords: [Point] = points.map({(p: Point) -> Point in
                return p + d * n
            })
            return [Self.init(points: coords)]
        }
        // for non-linear curves we need to create a set of curves
        let reduced = reduce()
        return reduced.map({
            return $0.curve.scale(distance: d)
        })
    }

    public func offset(t: Double, distance d: Double) -> Point {
        return internalOffset(t: t, distance: d).p
    }

    private func internalOffset(t: Double, distance d: Double) -> (c: Point, n: Vector, p: Point) {
        let c = point(at: t)
        let n = normal(at: t)
        return (c: c, n: n, p: c + d * n)
    }
}
