import Foundation

var bench = ""
var size = 0
var input: String?
var dbPath: String?

let args = Array(CommandLine.arguments.dropFirst())

var i = 0
while i < args.count {
    let arg = args[i]

    switch arg {
    case "--bench":
        bench = args[i + 1]
        i += 2
    case "--size":
        size = Int(args[i + 1])!
        i += 2
    case "--input":
        input = args[i + 1]
        i += 2
    case "--db":
        dbPath = args[i + 1]
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

case "db-crud":
    guard let path = dbPath else {
        print("--db <file> is required for db-crud")
        exit(1)
    }

    do {
        result = try runDBCRUD(dbPath: path, size: size)
    } catch {
        print("DB benchmark failed:", error)
        exit(1)
    }

default:
    print("Unknown benchmark")
    exit(1)
}

print("RESULT=\(result)")
