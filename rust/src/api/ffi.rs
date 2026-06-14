/// C FFI 导出：与 src/rust_ohos_app.c 中的符号保持一致，
/// 确保 ffigen 生成的 Dart 绑定能在鸿蒙等通过 cargokit 编译 Rust 的平台上正常工作。

#[no_mangle]
pub extern "C" fn sum(a: i32, b: i32) -> i32 {
    a + b
}

#[no_mangle]
pub extern "C" fn sum_long_running(a: i32, b: i32) -> i32 {
    std::thread::sleep(std::time::Duration::from_secs(5));
    a + b
}
