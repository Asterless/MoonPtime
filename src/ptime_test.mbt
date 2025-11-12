///|
test "ptime_epoch" {
  let epoch = Ptime::epoch()
  inspect(epoch.get_seconds(), content="0")
  inspect(epoch.get_picoseconds(), content="0")
}

///|
test "ptime_from_float" {
  let t = Ptime::of_float(1640995200.0) // 2022-01-01 00:00:00 UTC
  match t {
    Some(ptime) => {
      inspect(ptime.get_seconds(), content="1640995200")
      inspect(ptime.get_picoseconds(), content="0")
    }
    None => abort("Invalid time")
  }
}

///|
test "ptime_to_float" {
  let t = Ptime::of_seconds(1640995200L)
  let f = t.to_float()
  inspect(f, content="1640995200")
}

///|
test "ptime_comparison" {
  let t1 = Ptime::of_seconds(1000L)
  let t2 = Ptime::of_seconds(2000L)
  inspect(t1.compare(t2), content="-1") // t1 < t2
  inspect(t2.compare(t1), content="1") // t2 > t1
  inspect(t1.compare(t1), content="0") // t1 == t1
  assert_true(t1 < t2)
  assert_true(t1 <= t2)
  assert_true(t2 > t1)
  assert_true(t2 >= t1)
  assert_true(t1 == t1)
}

///|
test "ptime_ymd_hms" {
  // Test creating specific date time
  let t = Ptime::of_ymd_hms(2022, 1, 1, 12, 0, 0)
  match t {
    Some(_) =>
      inspect(
        t.unwrap().to_string(),
        content="{seconds: 1641038400, picoseconds: 0}",
      )
    None => abort("Invalid date")
  }

  // Test invalid date
  let invalid = Ptime::of_ymd_hms(2022, 2, 30, 12, 0, 0) // February doesn't have 30 days
  match invalid {
    Some(_) => abort("Should be invalid")
    None => assert_true(invalid is None)
  }
}

///|
test "ptime_rfc3339_formatting" {
  let epoch = Ptime::epoch()
  let rfc_str = epoch.to_rfc3339()
  // Epoch should be formatted as 1970-01-01T00:00:00Z
  inspect(rfc_str, content="1970-01-01T00:00:00Z")
}

///|
test "time_arithmetic" {
  let epoch = Ptime::epoch()
  let one_hour = Span::of_seconds(3600L)
  let later = epoch.add_span(one_hour)
  inspect(later.get_seconds(), content="3600")
  let earlier = later.sub_span(one_hour)
  inspect(earlier.get_seconds(), content="0")
  let diff = later.diff(earlier)
  inspect(diff.get_seconds(), content="3600")
}
