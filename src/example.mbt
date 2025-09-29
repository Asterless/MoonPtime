///| Ptime Library Examples
///
/// This file demonstrates various usage patterns of the Ptime library

///|
/// Example 1: Basic time point creation and conversion
pub fn example_basic_time() -> Unit {
  println("=== Basic Time Point Operations ===")

  // Create POSIX epoch
  let epoch = Ptime::epoch()
  println("POSIX Epoch: " + epoch.to_rfc3339())

  // Create time point from floating-point number
  let timestamp = 1672531200.0 // 2023-01-01 00:00:00 UTC
  match Ptime::of_float(timestamp) {
    Some(t) => {
      println(
        "Created from timestamp " +
        timestamp.to_string() +
        ": " +
        t.to_rfc3339(),
      )
      println("Convert back to float: " + t.to_float().to_string())
    }
    None => println("Invalid timestamp")
  }

  // Create from specific year, month, day, hour, minute, second
  match Ptime::of_ymd_hms(2025, 8, 22, 15, 30, 45) {
    Some(t) => println("2025-08-22 15:30:45 UTC: " + t.to_rfc3339())
    None => println("Invalid date time")
  }
}

///|
/// Example 2: Time span operations
pub fn example_time_spans() -> Unit {
  println("\n=== Time Span Operations ===")

  // Create different time spans
  let one_minute = Span::of_seconds(60L)
  let one_hour = Span::of_seconds(3600L)
  let one_day = Span::of_seconds(86400L)
  println("1 minute: " + one_minute.to_float().to_string() + " seconds")
  println("1 hour: " + one_hour.to_float().to_string() + " seconds")
  println("1 day: " + one_day.to_float().to_string() + " seconds")

  // Span arithmetic
  let total = one_hour.add(one_minute)
  println("1 hour + 1 minute = " + total.to_float().to_string() + " seconds")
  let diff = one_day.sub(one_hour)
  println("1 day - 1 hour = " + diff.to_float().to_string() + " seconds")
  let double_hour = one_hour.mul(2L)
  println("1 hour × 2 = " + double_hour.to_float().to_string() + " seconds")
}

///|
/// Example 3: Time point arithmetic
pub fn example_time_arithmetic() -> Unit {
  println("\n=== Time Point Arithmetic ===")

  // Create base time point
  match Ptime::of_ymd_hms(2025, 1, 1, 12, 0, 0) {
    Some(base_time) => {
      println("Base time: " + base_time.to_rfc3339())

      // Add time span
      let one_week = Span::of_seconds(7L * 24L * 3600L)
      let later = base_time.add_span(one_week)
      println("One week later: " + later.to_rfc3339())

      // Subtract time span
      let earlier = base_time.sub_span(one_week)
      println("One week earlier: " + earlier.to_rfc3339())

      // Calculate time difference
      let diff = later.diff(earlier)
      println(
        "Difference: " +
        diff.to_float().to_string() +
        " seconds = " +
        (diff.to_float() / 86400.0).to_string() +
        " days",
      )
    }
    None => println("Invalid base time")
  }
}

///|
/// Example 4: Time comparison
pub fn example_time_comparison() -> Unit {
  println("\n=== Time Comparison ===")
  let t0 = Ptime::of_seconds(1000L)
  let t1 = Ptime::of_seconds(2000L)
  let t2 = Ptime::of_seconds(1500L)
  println("Time point list:")
  println("  t0: " + t0.to_rfc3339())
  println("  t1: " + t1.to_rfc3339())
  println("  t2: " + t2.to_rfc3339())

  // Compare time points
  println("\nComparison results:")
  let cmp = t0.compare(t1)
  if cmp < 0 {
    println("t0 < t1")
  } else if cmp > 0 {
    println("t0 > t1")
  } else {
    println("t0 == t1")
  }
}

///|
/// Example 5: Span property checking
pub fn example_span_properties() -> Unit {
  println("\n=== Span Property Checking ===")
  let spans = [
    Span::of_seconds(100L), // Positive
    Span::of_seconds(-100L), // Negative
    Span::zero(), // Zero
    Span::of_ms(1500L), // Created from milliseconds
  ]
  let names = ["Positive span", "Negative span", "Zero span", "1.5 second span"]
  for i in 0..<spans.length() {
    let span = spans[i]
    let name = names[i]
    println(name + ":")
    println("  Seconds: " + span.seconds().to_string())
    println("  Picoseconds: " + span.picoseconds().to_string())
    println("  Is positive: " + span.is_positive().to_string())
    println("  Is negative: " + span.is_negative().to_string())
    println("  Is zero: " + span.is_zero().to_string())
    println("  Float value: " + span.to_float().to_string())
  }
}

///|
/// Example 6: Precision demonstration
pub fn example_precision() -> Unit {
  println("\n=== Precision Demonstration ===")

  // Create time with fractional part
  match Ptime::of_float(1640995200.123456) {
    Some(t) => {
      println("Timestamp with fraction: 1640995200.123456")
      println("Seconds part: " + t.seconds().to_string())
      println("Picoseconds part: " + t.picoseconds().to_string())
      println("Convert back to float: " + t.to_float().to_string())
    }
    None => println("Invalid time")
  }

  // Create span precise to picoseconds
  let precise_span : Span = { seconds: 1L, picoseconds: 123_456_789_000L }
  println("\nPrecise span: 1 second + 123,456,789,000 picoseconds")
  println(
    "Float representation: " + precise_span.to_float().to_string() + " seconds",
  )
}

///|
/// Run all examples
pub fn run_all_examples() -> Unit {
  example_basic_time()
  example_time_spans()
  example_time_arithmetic()
  example_time_comparison()
  example_span_properties()
  example_precision()
  println("\n=== All Examples Completed ===")
}
