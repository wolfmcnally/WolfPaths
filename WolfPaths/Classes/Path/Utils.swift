//
//  Utils.swift
//  WolfPaths
//
//  Created by Wolf McNally on 11/11/18.
//

import WolfGeometry
import WolfNumerics

public let defaultIntersectionThreshold = 0.5

internal class Utils {
    static let epsilon = 1.0e-5
    static let tau = 2.0 * .pi
    static let quart = .pi / 2.0

    // Legendre-Gauss abscissae with n=24 (x_i values, defined at i=n as the roots of the nth order Legendre polynomial Pn(x))
    static let Tvalues: ContiguousArray<Double> = [
        -0.0640568928626056260850430826247450385909,
        0.0640568928626056260850430826247450385909,
        -0.1911188674736163091586398207570696318404,
        0.1911188674736163091586398207570696318404,
        -0.3150426796961633743867932913198102407864,
        0.3150426796961633743867932913198102407864,
        -0.4337935076260451384870842319133497124524,
        0.4337935076260451384870842319133497124524,
        -0.5454214713888395356583756172183723700107,
        0.5454214713888395356583756172183723700107,
        -0.6480936519369755692524957869107476266696,
        0.6480936519369755692524957869107476266696,
        -0.7401241915785543642438281030999784255232,
        0.7401241915785543642438281030999784255232,
        -0.8200019859739029219539498726697452080761,
        0.8200019859739029219539498726697452080761,
        -0.8864155270044010342131543419821967550873,
        0.8864155270044010342131543419821967550873,
        -0.9382745520027327585236490017087214496548,
        0.9382745520027327585236490017087214496548,
        -0.9747285559713094981983919930081690617411,
        0.9747285559713094981983919930081690617411,
        -0.9951872199970213601799974097007368118745,
        0.9951872199970213601799974097007368118745
    ]

    // Legendre-Gauss weights with n=24 (w_i values, defined by a function linked to in the Bezier primer article)
    static let Cvalues: ContiguousArray<Double> = [
        0.1279381953467521569740561652246953718517,
        0.1279381953467521569740561652246953718517,
        0.1258374563468282961213753825111836887264,
        0.1258374563468282961213753825111836887264,
        0.1216704729278033912044631534762624256070,
        0.1216704729278033912044631534762624256070,
        0.1155056680537256013533444839067835598622,
        0.1155056680537256013533444839067835598622,
        0.1074442701159656347825773424466062227946,
        0.1074442701159656347825773424466062227946,
        0.0976186521041138882698806644642471544279,
        0.0976186521041138882698806644642471544279,
        0.0861901615319532759171852029837426671850,
        0.0861901615319532759171852029837426671850,
        0.0733464814110803057340336152531165181193,
        0.0733464814110803057340336152531165181193,
        0.0592985849154367807463677585001085845412,
        0.0592985849154367807463677585001085845412,
        0.0442774388174198061686027482113382288593,
        0.0442774388174198061686027482113382288593,
        0.0285313886289336631813078159518782864491,
        0.0285313886289336631813078159518782864491,
        0.0123412297999871995468056670700372915759,
        0.0123412297999871995468056670700372915759
    ]

    static func getABC(n: Int, S: Point, B: Point, E: Point, t: Double = 0.5) -> (A: Point, B: Point, C: Point) {
        let u = projectionRatio(n: n, t: t)
        let um = 1-u
        let C = Point(
            x: u*S.x + um*E.x,
            y: u*S.y + um*E.y
        )
        let s = abcRatio(n: n, t: t)
        let A = Point(
            x: B.x + (B.x-C.x)/s,
            y: B.y + (B.y-C.y)/s
        )
        return ( A:A, B:B, C:C )
    }

    static func abcRatio(n: Int, t: Double = 0.5) -> Double {
        // see ratio(t) note on http://pomax.github.io/bezierinfo/#abc
        assert(n == 2 || n == 3)
        if ( t == 0 || t == 1) {
            return t
        }
        let bottom = pow(t, Double(n)) + pow(1 - t, Double(n))
        let top = bottom - 1
        return abs(top/bottom)
    }

    static func projectionRatio(n: Int, t: Double = 0.5) -> Double {
        // see u(t) note on http://pomax.github.io/bezierinfo/#abc
        assert(n == 2 || n == 3)
        if (t == 0 || t == 1) {
            return t
        }
        let top = pow(1.0 - t, Double(n))
        let bottom = pow(t, Double(n)) + top
        return top/bottom
    }

//    static func map(_ v: Double,_ ds: Double,_ de: Double,_ ts: Double,_ te: Double) -> Double {
//        let d1 = de-ds
//        let d2 = te-ts
//        let v2 = v-ds
//        let r = v2/d1
//        return ts + d2*r
//    }

    static func lli8(_ x1: Double,_ y1: Double,_ x2: Double,_ y2: Double,_ x3:
        // TODO: implement line primitive (distinct from line segment) to rid of this function
        Double,_ y3: Double,_ x4: Double,_ y4: Double) -> Point? {
        let nx = (x1*y2-y1*x2)*(x3-x4)-(x1-x2)*(x3*y4-y3*x4)
        let ny = (x1*y2-y1*x2)*(y3-y4)-(y1-y2)*(x3*y4-y3*x4)
        let d = (x1-x2)*(y3-y4)-(y1-y2)*(x3-x4)
        if d == 0 {
            return nil
        }
        return Point( x: nx/d, y: ny/d )
    }

    static func lli4(_ p1: Point,_ p2: Point,_ p3: Point,_ p4: Point) -> Point? {
        // TODO: implement line primitive (distinct from line segment) to rid of this function
        let x1 = p1.x; let y1 = p1.y
        let x2 = p2.x; let y2 = p2.y
        let x3 = p3.x; let y3 = p3.y
        let x4 = p4.x; let y4 = p4.y
        return lli8(x1,y1,x2,y2,x3,y3,x4,y4)
    }

    // cube root function yielding real roots
    static private func crt(_ v: Double) -> Double {
        return (v < 0) ? -pow(-v,1.0/3.0) : pow(v,1.0/3.0)
    }

    static func roots(points: [Point], line: Line) -> [Double] {
        let order = points.count - 1
        let p = align(points, p1: line.from, p2: line.to)

        func clamp(_ n: Double) -> Double? {
            if n < -epsilon {
                return nil
            } else if n > 1.0 + epsilon {
                return nil
            } else if n ≈ (0.0, epsilon) {
                return 0.0
            } else if n ≈ (1.0, epsilon) {
                return 1.0
            }
            return n
        }

        switch order {
        case 2:
            let a = p[0].y
            let b = p[1].y
            let c = p[2].y
            let d = a - 2*b + c
            if abs(d) > epsilon {
                let m1 = -sqrt(b*b-a*c)
                let m2 = -a+b
                let v1: Double = -( m1+m2)/d
                let v2: Double = -(-m1+m2)/d
                return [v1, v2].compactMap(clamp)
            }
            else if a != b {
                // TODO: also fix in droots!
                return [(0.5) * a / (a-b)].compactMap(clamp)
            }
            else {
                return []
            }
        case 3:
            // see http://www.trans4mind.com/personal_development/mathematics/polynomials/cubicAlgebra.htm
            let pa = p[0].y
            let pb = p[1].y
            let pc = p[2].y
            let pd = p[3].y
            let temp1 = -pa
            let temp2 = 3*pb
            let temp3 = -3*pc
            let d = temp1 + temp2 + temp3 + pd
            if d == 0.0 {
                // TODO: epsilon testing ... use demos upgrade the quadratic to a cubic!
                let temp1 = points[0] * 3
                let temp2 = points[1] * (-6)
                let temp3 = points[2] * 3
                let a = (temp1 + temp2 + temp3)
                let temp4 = points[0] * (-3)
                let temp5 = points[1] * 3
                let b = (temp4 + temp5)
                let c = points[0]
                return roots(points: [c, b / 2.0 + c, a + b + c], line: line)
            }
            let a = (3*pa - 6*pb + 3*pc) / d
            let b = (-3*pa + 3*pb) / d
            let c = pa / d
            let p = (3*b - a*a)/3
            let p3 = p/3
            let q = (2*a*a*a - 9*a*b + 27*c)/27
            let q2 = q/2
            let discriminant = q2*q2 + p3*p3*p3
            if discriminant < 0 {
                let mp3 = -p/3
                let mp33 = mp3*mp3*mp3
                let r = sqrt( mp33 )
                let t = -q/(2*r)
                let cosphi = t < -1 ? -1 : t > 1 ? 1 : t
                let phi = acos(cosphi)
                let crtr = crt(r)
                let t1 = 2*crtr
                let x1 = t1 * cos(phi/3) - a/3
                let x2 = t1 * cos((phi+tau)/3) - a/3
                let x3 = t1 * cos((phi+2*tau)/3) - a/3
                return [x1, x2, x3].compactMap(clamp)
            }
            else if discriminant == 0 {
                let u1 = q2 < 0 ? crt(-q2) : -crt(q2)
                let x1 = 2*u1-a/3
                let x2 = -u1 - a/3
                return [x1,x2].compactMap(clamp)
            }
            else {
                let sd = sqrt(discriminant)
                let u1 = crt(-q2+sd)
                let v1 = crt(q2+sd)
                return [u1-v1-a/3].compactMap(clamp)
            }
        default:
            fatalError("unsupported")
        }
    }

    static func droots(_ a: Double, _ b: Double, _ c: Double, callback:(Double) -> Void) {
        // quadratic roots are easy
        // do something with each root
        let d: Double = a - 2.0*b + c
        if d != 0 {
            let m1 = -sqrt(b*b-a*c)
            let m2 = -a+b
            let v1 = -( m1+m2)/d
            let v2 = -(-m1+m2)/d
            callback(v1)
            callback(v2)
        }
        else if (b != c) && (d == 0) {
            callback((2*b-c)/(2*(b-c)))
        }
    }

    static func droots(_ a: Double, _ b: Double, callback: (Double) -> Void) {
        // linear roots are super easy
        // do something with the root, if it exists
        if a != b {
            callback(a / (a - b))
        }
    }

    static func droots(_ p: [Double]) -> [Double] {
        // quadratic roots are easy
        var result: [Double] = []
        switch p.count {
        case 3:
            droots(p[0], p[1], p[2]) {
                result.append($0)
            }
        case 2:
            droots(p[0], p[1]) {
                result.append($0)
            }
        default:
            fatalError("unsupported")
        }
        return result
    }

    static func mod(_ a: Int, _ n: Int) -> Int {
        precondition(n > 0, "modulus must be positive")
        let r = a % n
        return r >= 0 ? r : r + n
    }

    static func arcfn(_ t: Double, _ derivativeFn: (_ t: Double) -> Vector) -> Double {
        return derivativeFn(t).magnitude
    }

    static func length(_ derivativeFn: (_ t: Double) -> Vector) -> Double {
        let z: Double = 0.5
        let len = Tvalues.count
        var sum: Double = 0.0
        for i in 0..<len {
            let t = z * Tvalues[i] + z
            sum += Cvalues[i] * arcfn(t, derivativeFn)
        }
        return z * sum
    }

    static func align(_ points: [Point], p1: Point, p2: Point) -> [Point] {
        let tx = p1.x
        let ty = p1.y
        let a = -atan2(p2.y - ty, p2.x - tx)
        let cosa = cos(a)
        let sina = sin(a)
        return points.map {
            Point(
                x: ($0.x - tx) * cosa - ($0.y - ty) * sina,
                y: ($0.x - tx) * sina + ($0.y - ty) * cosa
            )
        }
    }

    static func closest(_ LUT: [Point],_ point: Point) -> (mdist: Double, mpos: Int) {
        assert(LUT.count > 0)
        var mdist = Double.infinity
        var mpos: Int? = nil
        for i in 0 ..< LUT.count {
            let p = LUT[i]
            let d = point.distance(to: p)
            if d < mdist {
                mdist = d
                mpos = i
            }
        }
        return ( mdist:mdist, mpos:mpos! )
    }

    static func pairiteration<C1, C2>(_ c1: Subcurve<C1>, _ c2: Subcurve<C2>, _ results: inout [Intersection], _ threshold: Double = defaultIntersectionThreshold) {
        let c1b = c1.curve.boundingBox
        let c2b = c2.curve.boundingBox
        if c1b.overlaps(c2b) == false {
            return
        }
        else if ((c1b.size.width + c1b.size.height) < threshold && (c2b.size.width + c2b.size.height) < threshold) {
            let l1 = Line(p0: c1.curve.from, p1: c1.curve.to)
            let l2 = Line(p0: c2.curve.from, p1: c2.curve.to)
            guard let intersection = l1.intersects(line: l2).first else {
                return
            }
            let t1 = intersection.t1
            let t2 = intersection.t2
            results.append(Intersection(t1: t1 * c1.t2 + (1.0 - t1) * c1.t1,
                                        t2: t2 * c2.t2 + (1.0 - t2) * c2.t1))
        }
        else {
            let cc1 = c1.split(at: 0.5)
            let cc2 = c2.split(at: 0.5)
            pairiteration(cc1.left, cc2.left, &results, threshold)
            pairiteration(cc1.left, cc2.right, &results, threshold)
            pairiteration(cc1.right, cc2.left, &results, threshold)
            pairiteration(cc1.right, cc2.right, &results, threshold)
        }
    }

    static func getccenter( _ p1: Point, _ p2: Point, _ p3: Point, _ interval: Interval<Double>) -> Arc {
        let d1 = p2 - p1
        let d2 = p3 - p2
        let d1p = Point(x: d1.dx * cos(quart) - d1.dy * sin(quart),
                          y: d1.dx * sin(quart) + d1.dy * cos(quart))
        let d2p = Point(x: d2.dx * cos(quart) - d2.dy * sin(quart),
                          y: d2.dx * sin(quart) + d2.dy * cos(quart))
        // chord midpoints
        let m1 = (p1 + p2) * 0.5
        let m2 = (p2 + p3) * 0.5
        // midpoint offsets
        let m1n = m1 + d1p
        let m2n = m2 + d2p
        // intersection of these lines:
        let oo = lli8(m1.x, m1.y, m1n.x, m1n.y, m2.x, m2.y, m2n.x, m2n.y)

        assert(oo != nil)

        let o: Point = oo!
        let r = o.distance(to: p1)
        // arc start/end values, over mid point:
        var s = atan2(p1.y - o.y, p1.x - o.x)
        let m = atan2(p2.y - o.y, p2.x - o.x)
        var e = atan2(p3.y - o.y, p3.x - o.x)
        // determine arc direction (cw/ccw correction)
        if s<e {
            // if s<m<e, arc(s, e)
            // if m<s<e, arc(e, s + tau)
            // if s<e<m, arc(e, s + tau)
            if s>m || m>e {
                s += tau
            }
            if s>e {
                swap(&s, &e)
            }
        }
        else {
            // if e<m<s, arc(e, s)
            // if m<e<s, arc(s, e + tau)
            // if e<s<m, arc(s, e + tau)
            if e<m && m<s {
                swap(&s, &e)
            }
            else {
                e += tau
            }
        }
        return Arc(origin: o, radius: r, startAngle: s, endAngle: e, interval: interval)
    }

    static func hull(_ p: [Point], _ t: Double) -> [Point] {
        let c: Int = p.count
        var q: [Point] = p
        q.reserveCapacity(c * (c+1) / 2) // reserve capacity ahead of time to avoid re-alloc
        // we lerp between all points (in-place), until we have 1 point left.
        var start: Int = 0
        for count in (1 ..< c).reversed()  {
            let end: Int = start + count
            for i in start ..< end {
                let pt = q[i].interpolated(to: q[i + 1], at: t)
                q.append(pt)
            }
            start = end + 1
        }
        return q
    }
}
