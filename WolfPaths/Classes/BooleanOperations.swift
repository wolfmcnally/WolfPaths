//
//  BooleanOperations.swift
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
    public func difference(_ path: CGPath) -> CGPath {
        return UIBezierPath(cgPath: self).fb_difference(UIBezierPath(cgPath: path)).cgPath
    }

    public func union(_ path: CGPath) -> CGPath {
        return UIBezierPath(cgPath: self).fb_union(UIBezierPath(cgPath: path)).cgPath
    }

    public func intersection(_ path: CGPath) -> CGPath {
        return UIBezierPath(cgPath: self).fb_intersect(UIBezierPath(cgPath: path)).cgPath
    }

    public func symmetricDifference(_ path: CGPath) -> CGPath {
        return UIBezierPath(cgPath: self).fb_xor(UIBezierPath(cgPath: path)).cgPath
    }
}
