import Foundation

var bench = ""
var size = 0
var input: String?

let args = CommandLine.arguments.dropFirst()

var i = 0
while i < args.count {
    let arg = Array(args)[i]

    switch arg {
    case "--bench":
        bench = Array(args)[i + 1]
        i += 2
    case "--size":
        size = Int(Array(args)[i + 1])!
        i += 2
    case "--input":
        input = Array(args)[i + 1]
        i += 2
    default:
        i += 1
    }
}

var result: UInt64 = 0

switch bench {

case "loop":
    result = runLoop(size)

case "fib-rec":
    result = runFibRecursive(UInt64(size))

case "fib-iter":
    result = runFibIterative(UInt64(size))

case "sort-bubble":
    result = runBubble(loadDataset(input!))

case "sort-quick":
    result = runQuick(loadDataset(input!))

case "sort-merge":
    result = runMerge(loadDataset(input!))

default:
    print("Unknown benchmark")
    exit(1)
}

print("RESULT=\(result)")
