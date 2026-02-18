package main

func RunLoop(size int) uint64 {
	var acc uint64 = 0

	for i := 0; i < size; i++ {
		acc += uint64(i)
	}

	return acc
}
