import Foundation

func runLoop(_ size: Int) -> UInt64 {
    var acc: UInt64 = 0

    for i in 0..<size {
        acc &+= UInt64(i)
    }

    return acc
}
