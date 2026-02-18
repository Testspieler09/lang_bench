# ==========
# Variables
# ==========

RUST_BIN=rust_bench
GO_BIN=go_bench
SWIFT_BIN=swift_bench

BIN_DIR=bin

DELTA_BIN ?= delta
DELTA_CONFIG=delta_benchmark.toml
DELTA_OUTPUT_DIR=bench_results

# ==========
# Help
# ==========

help:
	@echo ""
	@echo "Cross-language Benchmark Suite"
	@echo "================================"
	@echo ""
	@echo "Available targets:"
	@echo "  make help                    Show this help message"
	@echo ""
	@echo "  make gen-demo-data           Generate demo datasets"
	@echo "  make force-gen-demo-data     Regenerate datasets (overwrite)"
	@echo ""
	@echo "  make build                   Build all benchmarks"
	@echo "  make build-rust              Build Rust benchmark"
	@echo "  make build-go                Build Go benchmark"
	@echo "  make build-swift             Build Swift benchmark"
	@echo ""
	@echo "  make bench                   Run benchmarks using delta"
	@echo ""
	@echo "Binaries are placed in ./bin"
	@echo ""

# ==========
# Dataset Generation
# ==========

gen-demo-data:
	python3 shared/generator.py --size 10000 --output shared/dataset/random_10k.txt
	python3 shared/generator.py --size 100000 --output shared/dataset/random_100k.txt
	python3 shared/generator.py --size 1000000 --output shared/dataset/random_1m.txt

force-gen-demo-data:
	python3 shared/generator.py --size 10000 --output shared/dataset/random_10k.txt --force
	python3 shared/generator.py --size 100000 --output shared/dataset/random_100k.txt --force
	python3 shared/generator.py --size 1000000 --output shared/dataset/random_1m.txt --force

# ==========
# Build Targets
# ==========

build: build-rust build-go build-swift

build-rust:
	@echo "Building Rust..."
	cd rust && cargo build --release
	mkdir -p $(BIN_DIR)
	cp rust/target/release/$(RUST_BIN) $(BIN_DIR)/$(RUST_BIN)

build-go:
	@echo "Building Go..."
	cd go && go build -ldflags="-s -w" -o $(GO_BIN)
	mkdir -p $(BIN_DIR)
	mv go/$(GO_BIN) $(BIN_DIR)/$(GO_BIN)

build-swift:
	@echo "Building Swift..."
	cd swift && swift build -c release
	mkdir -p $(BIN_DIR)
	cp swift/.build/release/$(SWIFT_BIN) $(BIN_DIR)/$(SWIFT_BIN)

# ==========
# Benchmark
# ==========

bench:
	@echo "Running benchmarks with delta..."
	mkdir -p $(DELTA_OUTPUT_DIR)
	$(DELTA_BIN) -f $(DELTA_CONFIG) -o $(DELTA_OUTPUT_DIR)

# ==========
# Cleanup
# ==========

clean:
	@echo "Cleaning build artifacts..."
	rm -rf $(BIN_DIR)
	cd rust && cargo clean
	cd swift && swift package clean
	cd go && rm -f $(GO_BIN)

.PHONY: help gen-demo-data force-gen-demo-data build build-rust build-go build-swift bench clean
