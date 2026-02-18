pub fn run(size: usize) -> u64 {
    let mut acc: u64 = 0;

    for i in 0..size {
        acc = acc.wrapping_add(i as u64);
    }

    acc
}
