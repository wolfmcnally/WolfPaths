//
//  CGPathElements.swift
//  WolfPaths
//
//  Created by Wolf McNally on 10/18/18.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import CoreGraphics

extension CGPath {
    public var elements: [PathElement] {
        var result = [PathElement]()

        forEachElement { element in
            result.append(element)
        }

        return result
    }

    public var subpaths: [[PathElement]] {
        var result = [[PathElement]]()
        var currentPath: [PathElement]!

        forEachElement { element in
            if currentPath == nil {
                currentPath = [PathElement]()
            }
            currentPath.append(element)

            switch element {
            case .close:
                result.append(currentPath)
                currentPath = nil
            default:
                break
            }
        }

        if currentPath != nil {
            result.append(currentPath)
        }

        return result
    }

    private static func isFirstElementMove(_ elements: [PathElement]) -> Bool {
        switch elements.first! {
        case .move:
            return true
        default:
            return false
        }
    }

    public static func makeWithElements(_ elements: [PathElement]) -> CGPath {
        precondition(elements.count > 1, "Path must have more than one element.")
        precondition(isFirstElementMove(elements), "Path must start with a move.")

        let path = CGMutablePath()
        for element in elements {
            path.addElement(element)
        }
        return path.copy()!
    }

    public static func makeWithSubpaths(_ subpaths: [[PathElement]]) -> CGPath {
        let path = CGMutablePath()
        for elements in subpaths {
            precondition(elements.count > 1, "Path must have more than one element.")
            precondition(isFirstElementMove(elements), "Path must start with a move.")
            for element in elements {
                path.addElement(element)
            }
        }
        return path.copy()!
    }
}
