pub fn run_recursive(n: u64) -> u64 {
    fib_recursive(n)
}

fn fib_recursive(n: u64) -> u64 {
    match n {
        0 => 0,
        1 => 1,
        _ => fib_recursive(n - 1) + fib_recursive(n - 2),
    }
}

pub fn run_iterative(n: u64) -> u64 {
    if n == 0 {
        return 0;
    }

    let mut a: u64 = 0;
    let mut b: u64 = 1;

    for _ in 1..n {
        let temp = a.wrapping_add(b);
        a = b;
        b = temp;
    }

    b
}
