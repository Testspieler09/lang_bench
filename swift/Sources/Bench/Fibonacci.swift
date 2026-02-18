import Foundation

func runFibRecursive(_ n: UInt64) -> UInt64 {
    return fibRecursive(n)
}

func fibRecursive(_ n: UInt64) -> UInt64 {
    if n <= 1 {
        return n
    }
    return fibRecursive(n - 1) + fibRecursive(n - 2)
}

func runFibIterative(_ n: UInt64) -> UInt64 {
    if n == 0 {
        return 0
    }

    var a: UInt64 = 0
    var b: UInt64 = 1

    for _ in 1..<n {
        let temp = a &+ b
        a = b
        b = temp
    }

    return b
}
