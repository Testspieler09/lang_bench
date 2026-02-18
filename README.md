# Cross-Language Benchmark Suite

This repository provides a **cross-language benchmarking framework** for comparing Rust, Go, and Swift performance across various tasks, including loops, Fibonacci calculations, sorting algorithms, and more. Benchmarks are executed using [**Delta**](https://github.com/Testspieler09/delta), ensuring consistent measurement and result reporting.

## Quick Start (All-in-One)

This will **generate datasets, build all benchmarks, and run them** using Delta:

```bash
# 1. Generate all demo datasets
make gen-demo-data

# 2. Build Rust, Go, and Swift benchmarks
make build

# 3. Run all benchmarks with Delta
make bench
```

> Or in a single command line (Unix shells):

```bash
make gen-demo-data build bench
```

> If Delta is local:

```bash
DELTA_BIN=target/release/delta make gen-demo-data build bench
```

Results will appear in:

```
bench_results/
```

## Project Structure

```
.
├── delta_benchmark.toml         # Delta benchmark config
├── go                           # Go benchmark source
├── rust                         # Rust benchmark source
├── swift                        # Swift benchmark source
├── shared
│   ├── dataset                  # Shared input datasets
│   ├── generator.py             # Python dataset generator
│   └── schema.sql               # Optional database schema for future benchmarks
├── Makefile                     # Build and benchmark automation
├── README.md
└── LICENSE
```

Binaries are built into:

```
bin/
 ├── rust_bench
 ├── go_bench
 └── swift_bench
```

## Prerequisites

* **Rust** >= 1.70 (for Rust benchmarks)
* **Go** >= 1.22 (for Go benchmarks)
* **Swift** >= 5.9 (for Swift benchmarks)
* **Python 3** (for dataset generation)
* **Delta** benchmark tool (local binary or system PATH)

> If Delta is compiled locally, you can set its path with the `DELTA_BIN` environment variable:

```bash
export DELTA_BIN=target/release/delta
```

## Setup

### 1. Generate Input Datasets

Datasets are required for sorting benchmarks. You can generate them with:

```bash
# Generate default datasets
make gen-demo-data

# Force regeneration (overwrite existing files)
make force-gen-demo-data
```

This will create:

* `shared/dataset/random_10k.txt`
* `shared/dataset/random_100k.txt`
* `shared/dataset/random_1m.txt`

---

### 2. Build Benchmarks

Build all language binaries:

```bash
make build
```

Or build individual languages:

```bash
make build-rust
make build-go
make build-swift
```

> Binaries will be placed in the `bin/` directory.

## Running Benchmarks

The `bench` target executes all benchmarks using **Delta** and stores results in a directory (`bench_results` by default):

```bash
make bench
```

### Environment Variable

If Delta is not in your PATH, set `DELTA_BIN`:

```bash
DELTA_BIN=target/release/delta make bench
```

### Benchmark Output

* Execution times and memory usage are recorded per language and per benchmark.
* Results are stored in:

```
bench_results/
```

You can visualize or analyze the output using Delta’s built-in tools.

## Example Benchmarks

Delta runs a variety of benchmarks:

* **Loop** – simple CPU-intensive loop (`size=10_000_000`)
* **Fibonacci** – recursive and iterative (`size=40` for recursive, larger for iterative)
* **Sorting algorithms** – bubble, quick, and merge sort on shared datasets

Example CLI calls (internal to Delta):

```bash
./bin/rust_bench --bench loop --size 10000000
./bin/go_bench --bench sort-quick --size 100000 --input shared/dataset/random_100k.txt
./bin/swift_bench --bench fib-iter --size 1000000
```

## Cleanup

Remove built binaries and clean language-specific artifacts:

```bash
make clean
```

* Rust: `cargo clean`
* Go: removes `bin/go_bench`
* Swift: `swift package clean`
* Removes `bin/` folder

## Notes

* Benchmarks are **file-driven** for consistent cross-language comparison.
* The `checksum` of results is returned to prevent the compiler from optimizing away computation.
* Sorting and Fibonacci recursive benchmarks are intentionally slow to measure performance differences.
* Additional benchmarks (e.g., DB CRUD, heap sort, multithreaded tasks) can be added via `delta_benchmark.toml`.

## References

* [Delta Benchmark Tool](https://github.com/Testspieler09/delta)
* [Rust](https://www.rust-lang.org/)
* [Go](https://golang.org/)
* [Swift](https://swift.org/)

This README is now aligned with your **Makefile** and project layout.
