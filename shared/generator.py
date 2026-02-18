#!/usr/bin/env python3

import argparse
import random
from pathlib import Path


def generate_dataset(size: int, seed: int, output: Path):
    random.seed(seed)

    # Generate integers in a wide range to avoid trivial patterns
    data = [random.randint(-(10**9), 10**9) for _ in range(size)]

    with output.open("w") as f:
        for value in data:
            f.write(f"{value}\n")


def main():
    parser = argparse.ArgumentParser(
        description="Deterministic dataset generator for sorting benchmarks"
    )

    parser.add_argument(
        "--size", type=int, required=True, help="Number of integers to generate"
    )

    parser.add_argument(
        "--seed", type=int, default=42, help="Random seed (default: 42)"
    )

    parser.add_argument("--output", type=str, required=True, help="Output file path")

    parser.add_argument("--force", action="store_true", help="Overwrite existing file")

    args = parser.parse_args()

    output_path = Path(args.output)

    if output_path.exists() and not args.force:
        print(f"Error: {output_path} already exists. Use --force to overwrite.")
        return

    output_path.parent.mkdir(parents=True, exist_ok=True)

    print("Generating dataset:")
    print(f"  size  = {args.size}")
    print(f"  seed  = {args.seed}")
    print(f"  file  = {output_path}")

    generate_dataset(args.size, args.seed, output_path)

    print("Done.")


if __name__ == "__main__":
    main()
