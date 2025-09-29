///|
test "ptime_epoch" {
  let epoch = Ptime::epoch()
  inspect(epoch.seconds(), content="0")
  inspect(epoch.picoseconds(), content="0")
}

///|
test "ptime_from_float" {
  let t = Ptime::of_float(1640995200.0) // 2022-01-01 00:00:00 UTC
  match t {
    Some(ptime) => {
      inspect(ptime.seconds(), content="1640995200")
      inspect(ptime.picoseconds(), content="0")
    }
    None => inspect("Invalid time")
  }
}

///|
test "ptime_to_float" {
  let t = Ptime::of_seconds(1640995200L)
  let f = t.to_float()
  inspect(f, content="1640995200")
}

///|
test "span_operations" {
  let span1 = Span::of_seconds(3600L) // 1 hour
  let span2 = Span::of_seconds(1800L) // 30 minutes
  let sum = span1.add(span2)
  inspect(sum.seconds(), content="5400") // 1.5 hours
  let diff = span1.sub(span2)
  inspect(diff.seconds(), content="1800") // 30 minutes
  let doubled = span1.mul(2L)
  inspect(doubled.seconds(), content="7200") // 2 hours
}

///|
test "time_arithmetic" {
  let epoch = Ptime::epoch()
  let one_hour = Span::of_seconds(3600L)
  let later = epoch.add_span(one_hour)
  inspect(later.seconds(), content="3600")
  let earlier = later.sub_span(one_hour)
  inspect(earlier.seconds(), content="0")
  let diff = later.diff(earlier)
  inspect(diff.seconds(), content="3600")
}

///|
test "time_comparison" {
  let t1 = Ptime::of_seconds(1000L)
  let t2 = Ptime::of_seconds(2000L)
  inspect(t1.compare(t2), content="-1") // t1 < t2
  inspect(t2.compare(t1), content="1") // t2 > t1
  inspect(t1.compare(t1), content="0") // t1 == t1
}

///|
test "span_properties" {
  let positive = Span::of_seconds(100L)
  let negative = Span::of_seconds(-100L)
  let zero = Span::zero()
  inspect(positive.is_positive(), content="true")
  inspect(positive.is_negative(), content="false")
  inspect(positive.is_zero(), content="false")
  inspect(negative.is_positive(), content="false")
  inspect(negative.is_negative(), content="true")
  inspect(negative.is_zero(), content="false")
  inspect(zero.is_positive(), content="false")
  inspect(zero.is_negative(), content="false")
  inspect(zero.is_zero(), content="true")
}

///|
test "ptime_ymd_hms" {
  // Test creating specific date time
  let t = Ptime::of_ymd_hms(2022, 1, 1, 12, 0, 0)
  match t {
    Some(ptime) => inspect(ptime.seconds() > 0L, content="true")
    None => inspect("Invalid date")
  }

  // Test invalid date
  let invalid = Ptime::of_ymd_hms(2022, 2, 30, 12, 0, 0) // February doesn't have 30 days
  match invalid {
    Some(_) => inspect("Should be None")
    None =>
      inspect(
        "Correctly rejected invalid date",
        content="Correctly rejected invalid date",
      )
  }
}

///|
test "rfc3339_formatting" {
  let epoch = Ptime::epoch()
  let rfc_str = epoch.to_rfc3339()
  // Epoch should be formatted as 1970-01-01T00:00:00Z
  inspect(rfc_str, content="1970-01-01T00:00:00Z")
}
