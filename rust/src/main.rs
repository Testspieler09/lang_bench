mod db_crud;
mod fibonacci;
mod r#loop;
mod sorting;

use std::env;
use std::path::Path;

use db_crud::run as db_run;

fn main() {
    let args: Vec<String> = env::args().collect();

    let mut bench_name = "";
    let mut size: usize = 0;
    let mut input: Option<String> = None;
    let mut db_path: Option<&Path> = None;

    let mut i = 1;
    while i < args.len() {
        match args[i].as_str() {
            "--bench" => {
                bench_name = &args[i + 1];
                i += 2;
            }
            "--size" => {
                size = args[i + 1].parse().expect("Invalid size");
                i += 2;
            }
            "--input" => {
                input = Some(args[i + 1].clone());
                i += 2;
            }
            "--db" => {
                db_path = Some(Path::new(&args[i + 1]));
                i += 2;
            }
            _ => i += 1,
        }
    }

    let result: u64 = match bench_name {
        "loop" => r#loop::run(size),
        "fib-rec" => fibonacci::run_recursive(size as u64),
        "fib-iter" => fibonacci::run_iterative(size as u64),

        "sort-bubble" => {
            let data = sorting::load_dataset(input.expect("Missing --input"));
            sorting::run_bubble(data)
        }

        "sort-quick" => {
            let data = sorting::load_dataset(input.expect("Missing --input"));
            sorting::run_quick(data)
        }

        "sort-merge" => {
            let data = sorting::load_dataset(input.expect("Missing --input"));
            sorting::run_merge(data)
        }

        "db-crud" => {
            let path = db_path.expect("--db <file> is required for db-crud");
            db_run(path, size).expect("DB benchmark failed")
        }

        _ => {
            eprintln!("Unknown benchmark");
            std::process::exit(1);
        }
    };

    println!("RESULT={}", result);
}
