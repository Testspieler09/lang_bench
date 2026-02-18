import Foundation

func loadDataset(_ path: String) -> [Int64] {
    let content = try! String(contentsOfFile: path)
    return content
        .split(separator: "\n")
        .map { Int64($0)! }
}

func checksum(_ data: [Int64]) -> UInt64 {
    var sum: UInt64 = 0

    for v in data {
        sum &+= UInt64(bitPattern: v)
    }

    return sum
}

func runBubble(_ data: [Int64]) -> UInt64 {
    var arr = data
    let n = arr.count

    for i in 0..<n {
        for j in 0..<(n - i - 1) {
            if arr[j] > arr[j + 1] {
                arr.swapAt(j, j + 1)
            }
        }
    }

    return checksum(arr)
}

func runQuick(_ data: [Int64]) -> UInt64 {
    var arr = data
    quicksort(&arr, 0, arr.count - 1)
    return checksum(arr)
}

func quicksort(_ arr: inout [Int64], _ low: Int, _ high: Int) {
    if low < high {
        let p = partition(&arr, low, high)
        quicksort(&arr, low, p - 1)
        quicksort(&arr, p + 1, high)
    }
}

func partition(_ arr: inout [Int64], _ low: Int, _ high: Int) -> Int {
    let pivot = arr[high]
    var i = low

    for j in low..<high {
        if arr[j] < pivot {
            arr.swapAt(i, j)
            i += 1
        }
    }

    arr.swapAt(i, high)
    return i
}

func runMerge(_ data: [Int64]) -> UInt64 {
    var arr = data
    mergeSort(&arr)
    return checksum(arr)
}

func mergeSort(_ arr: inout [Int64]) {
    if arr.count <= 1 {
        return
    }

    let mid = arr.count / 2
    var left = Array(arr[..<mid])
    var right = Array(arr[mid...])

    mergeSort(&left)
    mergeSort(&right)

    arr = merge(left, right)
}

func merge(_ left: [Int64], _ right: [Int64]) -> [Int64] {
    var result: [Int64] = []
    result.reserveCapacity(left.count + right.count)

    var i = 0
    var j = 0

    while i < left.count && j < right.count {
        if left[i] <= right[j] {
            result.append(left[i])
            i += 1
        } else {
            result.append(right[j])
            j += 1
        }
    }

    while i < left.count {
        result.append(left[i])
        i += 1
    }

    while j < right.count {
        result.append(right[j])
        j += 1
    }

    return result
}
