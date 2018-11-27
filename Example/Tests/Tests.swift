import XCTest
import WolfPaths
import CoreGraphics
import WolfGeometry
import WolfPipe
import WolfNumerics

//class Tests: XCTestCase {
//    func testPathFromCGPath() {
//        let cgPath = CGMutablePath()
//        cgPath.move(to: .zero)
//        cgPath.addLine(to: CGPoint(x: 100, y: 100))
//        cgPath.addLine(to: CGPoint(x: -100, y: 100))
//        cgPath.closeSubpath()
//        cgPath.move(to: .zero)
//        dump(cgPath)
//
//        let path = cgPath |> toPath
//        dump(path)
//
//        let cgPath2 = path |> toCGPath
//        dump(cgPath2)
//    }
//
//    func testAngle() {
//        let o = Point(x: 1, y: 5)
//        let p1 = Point(x: 11, y: 15)
//        let p2 = Point(x: 11, y: 2)
//        let a = angleAtVertex(o: o, p1, p2) |> degrees
//        print(a)
//    }
//}
