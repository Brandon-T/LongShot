//
//  Algorithms.swift
//  LongShot
//
//  Created by Soner Yuksel on 2019-06-19.
//  Copyright © 2019 XIO. All rights reserved.
//

import Foundation

/// Implementation of Insertion Sort Algorithm using a generic Array
///
/// Insertion sort is a simple sorting algorithm that builds the final sorted array (or list)
/// one item at a time
///
/// It is much less efficient on large lists than more advanced algorithms
///
/// Efficient for (quite) small data sets, much like other quadratic sorting algorithms
/// More efficient in practice than most other simple quadratic (i.e., O(n2))
/// algorithms such as selection sort or bubble sort
///
/// Stable; i.e., does not change the relative order of elements with equal keys
/// In-place; i.e., only requires a constant amount O(1) of additional memory space
///
/// How it works: Algorithm traverses the list of elements from start to end
/// For every element on the left side of the array (trversing back to start)
/// It will check every element and swap the element if it is smaller
///

/// Usage:
///
/// var testArrayInsertionSort = [8, 2, 5, 3, 11, 4, 6]
///
/// insertionSort(&testArrayInsertionSort)
/// print("\(testArrayInsertionSort)") -> 2, 3, 4, 5, 6, 8, 11
///
///                 -> Traverse every element left to right
///                     5
///             2 - 8 -   - 3 - 11 - 4 - 6
///
///                  <- Compare and swap right to left
///

func insertionSort<T: Comparable>(_ array: inout [T]) {
    
    /// Exit condition where array has at least 2 elements
    guard array.count >= 2 else {
        return
    }
    
    /// Traverse every element left to right
    for traverseIndex in 1...array.count {
        /// Compare and swap right to left
        for elementIndex in (1..<traverseIndex).reversed() {
            if array[elementIndex] < array[elementIndex - 1] {
                array.swapAt(elementIndex, elementIndex - 1)
            }
        }
    }
    
}
