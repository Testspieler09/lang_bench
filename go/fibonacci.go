package main

func RunFibRecursive(n uint64) uint64 {
	return fibRecursive(n)
}

func fibRecursive(n uint64) uint64 {
	if n <= 1 {
		return n
	}
	return fibRecursive(n-1) + fibRecursive(n-2)
}

func RunFibIterative(n uint64) uint64 {
	if n == 0 {
		return 0
	}

	var a uint64 = 0
	var b uint64 = 1

	for i := uint64(1); i < n; i++ {
		a, b = b, a+b
	}

	return b
}
