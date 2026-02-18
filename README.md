# Cross-Language Benchmark Suite

This repository provides a **cross-language benchmarking framework** for comparing **Rust, Go, and Swift** performance across multiple workloads:

* CPU loops
* Fibonacci (recursive & iterative)
* Sorting algorithms
* SQLite DB CRUD benchmark

Benchmarks are executed using [**Delta**](https://github.com/Testspieler09/delta) to ensure consistent measurement and structured output.

## Quick Start (All-in-One)

Generate datasets, build all languages, and run CPU benchmarks:

```bash
make gen-demo-data
make build
make bench
```

Or in one line:

```bash
make gen-demo-data build bench
```

If Delta is built locally:

```bash
DELTA_BIN=target/release/delta make bench
```

Results will appear in:

```
bench_results/
```

## Database Benchmarks (SQLite CRUD)

The suite also includes a **cross-language SQLite CRUD benchmark**.

To run DB benchmarks:

```bash
make build
make bench-db
```

Results will appear in:

```
bench_results_db/
```

The database is automatically reset before DB benchmarks via:

```bash
make db-setup
```

This:

* Creates `shared/db/`
* Deletes old `demo.sqlite`
* Loads schema from `shared/schema.sql`

## Project Structure

```
.
├── delta_benchmark.toml          # CPU benchmark config
├── delta_db_benchmark.toml       # DB benchmark config
├── go                            # Go source
├── rust                          # Rust source
├── swift                         # Swift source
├── shared
│   ├── dataset                   # Sorting datasets
│   ├── db
│   │   └── demo.sqlite           # SQLite database (generated)
│   ├── generator.py              # Dataset generator
│   └── schema.sql                # SQLite schema
├── bin                           # Built binaries
├── Makefile
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

* **Rust** >= 1.93
* **Go** >= 1.25
* **Swift** >= 6.2
* **Python 3**
* **SQLite3 CLI** (for `db-setup`)
* **Delta** benchmark tool

If Delta is not in your PATH:

```bash
export DELTA_BIN=target/release/delta
```

## Available Make Targets

### Help

```bash
make help
```

### Dataset Generation

```bash
make gen-demo-data
make force-gen-demo-data
```

Generates:

* `shared/dataset/random_10k.txt`
* `shared/dataset/random_100k.txt`
* `shared/dataset/random_1m.txt`

### Build

Build all languages:

```bash
make build
```

Or individually:

```bash
make build-rust
make build-go
make build-swift
```

Binaries are placed in:

```
./bin
```

### Benchmarks

#### CPU Benchmarks

```bash
make bench
```

Uses:

```
delta_benchmark.toml
```

Output:

```
bench_results/
```

#### Database Benchmarks

```bash
make bench-db
```

Uses:

```
delta_db_benchmark.toml
```

Output:

```
bench_results_db/
```

### Cleanup

```bash
make clean
```

Removes:

* `bin/`
* Rust target directory
* Swift build artifacts
* Go binary

## Example CLI Commands (Manual)

These are the commands Delta runs internally:

### Loop

```bash
./bin/rust_bench --bench loop --size 10000000
```

### Sorting

```bash
./bin/go_bench --bench sort-quick --size 100000 --input shared/dataset/random_100k.txt
```

### Fibonacci

```bash
./bin/swift_bench --bench fib-rec --size 40
```

### DB CRUD

```bash
./bin/rust_bench --bench db-crud --db shared/db/demo.sqlite --size 1000
./bin/go_bench --bench db-crud --db shared/db/demo.sqlite --size 1000
./bin/swift_bench --bench db-crud --db shared/db/demo.sqlite --size 1000
```

## Design Notes

* Benchmarks return a `checksum` to prevent compiler optimizations.
* Sorting datasets are shared across languages for fairness.
* DB benchmarks:
  * Reset schema each run
  * Use transactions for realistic performance
  * Use identical SQL schema across languages
* Delta ensures consistent timing & reporting.
* CPU and DB benchmarks are separated into different Delta configs for clarity.

## References

* [Delta](https://github.com/Testspieler09/delta)
* [Rust](https://www.rust-lang.org/)
* [Go](https://golang.org/)
* [Swift](https://swift.org/)
