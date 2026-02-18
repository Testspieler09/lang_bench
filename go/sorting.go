package main

import (
	"bufio"
	"os"
	"strconv"
)

func LoadDataset(path string) []int64 {
	file, err := os.Open(path)
	if err != nil {
		panic(err)
	}
	defer file.Close()

	var data []int64
	scanner := bufio.NewScanner(file)

	for scanner.Scan() {
		v, err := strconv.ParseInt(scanner.Text(), 10, 64)
		if err != nil {
			panic(err)
		}
		data = append(data, v)
	}

	return data
}

func checksum(data []int64) uint64 {
	var sum uint64 = 0

	for _, v := range data {
		sum += uint64(v)
	}

	return sum
}

func RunBubble(data []int64) uint64 {
	n := len(data)

	for i := range n {
		for j := 0; j < n-i-1; j++ {
			if data[j] > data[j+1] {
				data[j], data[j+1] = data[j+1], data[j]
			}
		}
	}

	return checksum(data)
}

func RunQuick(data []int64) uint64 {
	quicksort(data, 0, len(data)-1)
	return checksum(data)
}

func quicksort(arr []int64, low, high int) {
	if low < high {
		p := partition(arr, low, high)
		quicksort(arr, low, p-1)
		quicksort(arr, p+1, high)
	}
}

func partition(arr []int64, low, high int) int {
	pivot := arr[high]
	i := low

	for j := low; j < high; j++ {
		if arr[j] < pivot {
			arr[i], arr[j] = arr[j], arr[i]
			i++
		}
	}

	arr[i], arr[high] = arr[high], arr[i]
	return i
}

func RunMerge(data []int64) uint64 {
	mergeSort(data)
	return checksum(data)
}

func mergeSort(arr []int64) {
	if len(arr) <= 1 {
		return
	}

	mid := len(arr) / 2
	left := make([]int64, mid)
	right := make([]int64, len(arr)-mid)

	copy(left, arr[:mid])
	copy(right, arr[mid:])

	mergeSort(left)
	mergeSort(right)

	merge(arr, left, right)
}

func merge(result, left, right []int64) {
	i, j, k := 0, 0, 0

	for i < len(left) && j < len(right) {
		if left[i] <= right[j] {
			result[k] = left[i]
			i++
		} else {
			result[k] = right[j]
			j++
		}
		k++
	}

	for i < len(left) {
		result[k] = left[i]
		i++
		k++
	}

	for j < len(right) {
		result[k] = right[j]
		j++
		k++
	}
}
