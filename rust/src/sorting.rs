use std::fs::File;
use std::io::{BufRead, BufReader};

// Helper
pub fn load_dataset(path: String) -> Vec<i64> {
    let file = File::open(path).expect("Unable to open dataset file");
    let reader = BufReader::new(file);

    reader
        .lines()
        .map(|line| {
            line.expect("Invalid line")
                .parse::<i64>()
                .expect("Invalid number")
        })
        .collect()
}

fn checksum(data: &[i64]) -> u64 {
    data.iter().fold(0u64, |acc, &x| acc.wrapping_add(x as u64))
}

// Bubblesort
pub fn run_bubble(mut data: Vec<i64>) -> u64 {
    let n = data.len();
    for i in 0..n {
        for j in 0..(n - i - 1) {
            if data[j] > data[j + 1] {
                data.swap(j, j + 1);
            }
        }
    }
    checksum(&data)
}

// Quicksort
pub fn run_quick(mut data: Vec<i64>) -> u64 {
    quicksort(&mut data);
    checksum(&data)
}

fn quicksort(arr: &mut [i64]) {
    if arr.len() <= 1 {
        return;
    }

    let pivot_index = partition(arr);
    let (left, right) = arr.split_at_mut(pivot_index);
    quicksort(left);
    quicksort(&mut right[1..]);
}

fn partition(arr: &mut [i64]) -> usize {
    let len = arr.len();
    let pivot = arr[len - 1];
    let mut i = 0;

    for j in 0..len - 1 {
        if arr[j] < pivot {
            arr.swap(i, j);
            i += 1;
        }
    }

    arr.swap(i, len - 1);
    i
}

// Mergesort
pub fn run_merge(mut data: Vec<i64>) -> u64 {
    merge_sort(&mut data);
    checksum(&data)
}

fn merge_sort(arr: &mut [i64]) {
    let len = arr.len();
    if len <= 1 {
        return;
    }

    let mid = len / 2;
    merge_sort(&mut arr[..mid]);
    merge_sort(&mut arr[mid..]);

    let mut merged = arr.to_vec();
    merge(&arr[..mid], &arr[mid..], &mut merged[..]);
    arr.copy_from_slice(&merged);
}

fn merge(left: &[i64], right: &[i64], result: &mut [i64]) {
    let mut i = 0;
    let mut j = 0;
    let mut k = 0;

    while i < left.len() && j < right.len() {
        if left[i] <= right[j] {
            result[k] = left[i];
            i += 1;
        } else {
            result[k] = right[j];
            j += 1;
        }
        k += 1;
    }

    while i < left.len() {
        result[k] = left[i];
        i += 1;
        k += 1;
    }

    while j < right.len() {
        result[k] = right[j];
        j += 1;
        k += 1;
    }
}
