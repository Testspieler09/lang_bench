package main

import (
	"fmt"
	"os"
	"strconv"
)

func main() {
	var bench string
	var size int
	var input string

	args := os.Args[1:]

	for i := 0; i < len(args); i++ {
		switch args[i] {
		case "--bench":
			bench = args[i+1]
			i++
		case "--size":
			v, err := strconv.Atoi(args[i+1])
			if err != nil {
				panic("invalid size")
			}
			size = v
			i++
		case "--input":
			input = args[i+1]
			i++
		}
	}

	var result uint64

	switch bench {

	case "loop":
		result = RunLoop(size)

	case "fib-rec":
		result = RunFibRecursive(uint64(size))

	case "fib-iter":
		result = RunFibIterative(uint64(size))

	case "sort-bubble":
		data := LoadDataset(input)
		result = RunBubble(data)

	case "sort-quick":
		data := LoadDataset(input)
		result = RunQuick(data)

	case "sort-merge":
		data := LoadDataset(input)
		result = RunMerge(data)

	default:
		fmt.Println("Unknown benchmark")
		os.Exit(1)
	}

	fmt.Printf("RESULT=%d\n", result)
}
