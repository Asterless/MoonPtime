///|
fn main {
  // Demonstrate basic usage of Ptime library

  // Create POSIX epoch time point
  let epoch = @lib.Ptime::epoch()
  println("POSIX Epoch: " + epoch.to_rfc3339())

  // Create time point from floating-point number
  let now = @lib.Ptime::of_float(1640995200.0) // 2022-01-01 00:00:00 UTC
  match now {
    Some(t) => println("From float: " + t.to_rfc3339())
    None => println("Invalid time")
  }

  // Create time span and perform operations
  let one_hour = @lib.Span::of_seconds(3600L)
  println("One hour: " + one_hour.to_float().to_string() + " seconds")

  // Add span to time point
  match now {
    Some(t) => {
      let later = t.add_span(one_hour)
      println("One hour later: " + later.to_rfc3339())
    }
    None => ()
  }
}
