//
//  Algorithms.swift
//  LongShot
//
//  Created by Soner Yuksel on 2019-06-19.
//  Copyright © 2019 XIO. All rights reserved.
//

import Foundation


/*
* Swift Implementation for some commonly used Sorting & Searching Algorithms
*
* Insertion Sort using in place Array - (Fast sorting algorithm in smaller data size)
*
* Merge Sort as an example of Divide & Conquer Sort Algorithm
*
* Binary Search as a Divide & Conquer Search Algorithm
*
* Work In Progress:
* - Quick Sort Algorithm
*/


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


/// Implementation of Merge Sort Algorithm using a generic Array
///
/// Merge sort is a s an efficient, general-purpose, comparison-based sorting algorithm
///
/// Merge sort is a divide and conquer algorithm
///
/// In sorting n objects, merge sort has an average and worst-case performance of O(n log n)
///
/// Merge sort is more efficient than quicksort for some types of lists
/// if the data to be sorted can only be efficiently accessed sequentially
///
/// How it works: Conceptually, a merge sort works as follows:
/// Divide the unsorted list into n sublists, each containing one element
/// Repeatedly merge sublists to produce new sorted sublists until there is only one sublist remaining.
///

/// Usage:
///
/// var testArrayMergeSort = [8, 2, 5, 3, 11, 4, 6]
///
/// let sortedArray = mergeSort(testArrayMergeSort)
/// print("Sorted \(sortedArray)") -> 2, 3, 4, 5, 6, 8, 11
///
///      ->  Divide array into pieces and small chunks until it is single element
///
///             8 - 2 - 5 - 3    11 - 4 - 6 - 1
///             8 - 2   5 - 3
///                 8 - 2
///
///      ->  Merge them back by sorting


func mergeSort<T: Comparable>(_ array: [T]) -> [T] {
    
    /// Exit condition where array has at least 2 elements
    guard array.count > 1 else {
        return array
    }
    
    /// Find the middle point
    let middleIndex = array.count / 2
    
    /// Create left- right array using array slices
    /// Divide an Conquer part of Merge Sort
    let leftPile = mergeSort(Array(array.prefix(upTo: middleIndex)))
    let rightPile =  mergeSort(Array(array.suffix(from: middleIndex)))
    
    return merge(leftPile, rightPile)
}


// Merge Function that needs to be sorting and merging both sides
func merge<T: Comparable>(_ leftArray: [T], _ rightArray: [T]) -> [T] {
    
    /// The Indexes used for either side of the slices
    var leftIndex = 0
    var rightIndex = 0
    
    var resultArray = [T]()
    
    /// Traverse from left to right in slices and increment side index
    /// According to which one is smaller and added to the resultArray
    while leftIndex < leftArray.count && rightIndex < rightArray.count {
        if leftArray[leftIndex] < rightArray[rightIndex] {
            
            resultArray.append(leftArray[leftIndex])
            leftIndex += 1
        }
        else if (leftArray[leftIndex] > rightArray[rightIndex]) {
            resultArray.append(rightArray[rightIndex])
            rightIndex += 1
        }
        else {
            resultArray.append(leftArray[leftIndex])
            resultArray.append(rightArray[rightIndex])
            
            leftIndex += 1
            rightIndex += 1
        }
        
    }
    
    /// Add the rest of the content in slices if one side is already added to resultArray
    if leftIndex == leftArray.count {
        resultArray.append(contentsOf: rightArray[rightIndex...])
    } else {
        resultArray.append(contentsOf: leftArray[leftIndex...])
    }
    
    
    return resultArray
}


/// Implementation of Binart Search Algorithm in swift using Range
///
/// Binary search, also known as half-interval search,[1] logarithmic search,[2] or binary chop,[3]
/// is a search algorithm that finds the position of a target value within a sorted array
///
/// Binary search is a divide and conquer algorithm which can search very fast in SORTED LIST
///
/// Binary search runs in logarithmic time in the worst case, making O(log n) comparisons
///
/// Binary Search is a efficient searching algorithm
/// So in some cases it might be a good practice to sort first and use binary search
///
/// How it works: Conceptually, a binary search works as follows:
/// Binary search begins by comparing the middle element of the array with the target value
/// The target value matches the middle element, its position in the array is returned
/// The target value is less than the middle element, the search continues in the lower half of the array
/// The target value is greater than the middle element, the search continues in the upper half of the array

/// Usage:
///
/// var testArrayBinarySearch = [2, 4, 5, 6, 7, 8, 9]
///
/// let searchResult = binarySearch(testArrayBinarySearch, for: 6)
///
/// if let result = searchResult {
///     print("\(result)")
/// }
///
///      ->  Divide array into pieces and small chunks and choose left or right side recursively
///
///             2 - 3 - 4 - 5    6 - 8 - 9 - 10
///             2 - 3   4 -5
///                 3 - 4
///
///      ->  Continue breaking into pieces until you find the element or return

func binarySearch<T: Comparable>(_ array: [T], for element: T, in range:Range<Int>? = nil) -> Int? {
    
    // Check if it is the initial call or divide call
    let range = range ?? 0..<array.count
    
    // Exit Condition when we cant divide anymore
    guard range.lowerBound < range.upperBound else {
        return nil
    }
    
    let size = range.upperBound - range.lowerBound
    let middleIndex = range.lowerBound + size / 2
    
    if array[middleIndex] == element {
        return middleIndex
    }
    else if array[middleIndex] > element {
        return binarySearch(array, for: element, in: range.lowerBound..<middleIndex)
    }
    else {
        return binarySearch(array, for: element, in: middleIndex+1..<range.upperBound)
    }
    
}
