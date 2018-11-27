//
//  BoundingVolumeNode.swift
//  WolfPaths
//
//  Created by Wolf McNally on 11/19/18.
//

// https://en.wikipedia.org/wiki/Bounding_volume_hierarchy

struct BoundingVolumeNode {
    let boundingBox: BoundingBox
    let nodeType: NodeType

    enum NodeType {
        case leaf(object: Bounded, elementIndex: Int)
        case `internal`(list: [BoundingVolumeNode])
    }

    init(objects: [Bounded]) {
        self.init(slice: ArraySlice<Bounded>(objects))
    }

    func visit(callback: (BoundingVolumeNode, Int) -> Bool) {
        self.visit(callback: callback, currentDepth: 0)
    }

    func intersects(node other: BoundingVolumeNode, callback: (Bounded, Bounded, Int, Int) -> Void) {
        guard self.boundingBox.overlaps(other.boundingBox) else {
            return // nothing to do
        }

        switch nodeType {
        case let .leaf(object1, elementIndex1):
            switch other.nodeType {
            case let .leaf(object2, elementIndex2):
                callback(object1, object2, elementIndex1, elementIndex2)
            case let .internal(list: list2):
                list2.forEach {
                    intersects(node: $0, callback: callback)
                }
            }
        case let .internal(list: list1):
            switch other.nodeType {
            case .leaf:
                list1.forEach {
                    $0.intersects(node: other, callback: callback)
                }
            case let .internal(list: list2):
                list1.forEach { node1 in
                    list2.forEach { node2 in
                        node1.intersects(node: node2, callback: callback)
                    }
                }
            }
        }
    }

    // MARK: - private

    private func visit(callback: (BoundingVolumeNode, Int) -> Bool, currentDepth depth: Int) {
        guard callback(self, depth) == true else {
            return
        }
        if case let .internal(list: list) = self.nodeType {
            list.forEach {
                $0.visit(callback: callback, currentDepth: depth+1)
            }
        }
    }

    private init(slice: ArraySlice<Bounded>) {
        switch slice.count {
        case 0:
            self.nodeType = .internal(list: [])
            self.boundingBox = BoundingBox.empty
        case 1:
            let object = slice.first!
            self.nodeType = .leaf(object: object, elementIndex: slice.startIndex)
            self.boundingBox = object.boundingBox
        default:
            let startIndex = slice.startIndex
            let splitIndex = ( slice.startIndex + slice.endIndex ) / 2
            let endIndex   = slice.endIndex
            let left    = BoundingVolumeNode(slice: slice[startIndex..<splitIndex])
            let right   = BoundingVolumeNode(slice: slice[splitIndex..<endIndex])
            let boundingBox = BoundingBox(first: left.boundingBox, second: right.boundingBox)
            self.boundingBox = boundingBox
            if slice.count > 2 {
                // an optimization when at least one of left or right is not a leaf node
                // check the surface-area heuristic to see if we actually get a better result by putting
                // the descendents of left and right as child nodes of self
                func descendents(_ node: BoundingVolumeNode) -> [BoundingVolumeNode] {
                    switch node.nodeType {
                    case .leaf(_):
                        return [node]
                    case let .internal(list):
                        return list
                    }
                }
                let leftDescendents     = descendents(left)
                let rightDescendents    = descendents(right)
                let costLeft            = Double(leftDescendents.count) * ( 1.0 - left.boundingBox.area / boundingBox.area )
                let costRight           = Double(rightDescendents.count) * ( 1.0 - right.boundingBox.area / boundingBox.area )
                if 2 > costLeft + costRight {
                    self.nodeType = .internal(list: leftDescendents + rightDescendents)
                    return
                }
            }
            self.nodeType = .internal(list: [left, right])
        }
    }
}
