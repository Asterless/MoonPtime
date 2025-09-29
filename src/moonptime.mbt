///| Core Types and Constants

///|
/// RFC 3339 time point representing time since POSIX epoch (1970-01-01 00:00:00 UTC).
/// Uses (seconds, picoseconds) representation with picosecond precision.
pub struct Ptime {
  /// Number of seconds since POSIX epoch, can be negative (for dates before 1970)
  seconds : Int64
  /// Picoseconds component, range [0, 999_999_999_999]
  picoseconds : Int64
} derive(Eq, Show)

///|
/// Time span representing the duration between two time points.
/// Uses (seconds, picoseconds) representation, can be positive or negative.
pub struct Span {
  /// Number of seconds, can be negative
  seconds : Int64
  /// Picoseconds component, range [-999_999_999_999, 999_999_999_999]
  picoseconds : Int64
} derive(Eq, Show)

///|
/// Number of picoseconds per second
let ps_per_s : Int64 = 1_000_000_000_000L

///| Ptime Construction

///|
/// Creates a time point representing the POSIX epoch (1970-01-01 00:00:00 UTC).
///
/// Returns a `Ptime` representing the Unix epoch with both seconds and picoseconds set to zero.
///
/// Example:
///
/// ```moonbit
/// let epoch = Ptime::epoch()
/// inspect(epoch.seconds(), content="0")
/// inspect(epoch.picoseconds(), content="0")
/// ```
///
pub fn Ptime::epoch() -> Ptime {
  { seconds: 0L, picoseconds: 0L }
}

///|
/// Creates a time point from a floating-point number representing seconds since the POSIX epoch.
///
/// Parameters:
///
/// * `f` : The floating-point time value in seconds since epoch.
///
/// Returns `Some(Ptime)` if the input is valid, `None` if the input is NaN or infinite.
/// The fractional part is converted to picoseconds with appropriate precision.
///
/// Example:
///
/// ```moonbit
/// let time = Ptime::of_float(1640995200.123)
/// inspect(time.unwrap().seconds(), content="1640995200")
/// ```
///
pub fn Ptime::of_float(f : Double) -> Ptime? {
  if f.is_nan() || f.is_inf() {
    None
  } else {
    let seconds = f.floor().to_int64()
    let frac = f - f.floor()
    let picoseconds = (frac * ps_per_s.to_double()).to_int64()
    Some(Ptime::normalize({ seconds, picoseconds }))
  }
}

///|
/// Creates a time point from an integer number of seconds since the POSIX epoch.
///
/// Parameters:
///
/// * `s` : The number of seconds since epoch as an `Int64`.
///
/// Returns a `Ptime` with the specified seconds and zero picoseconds.
///
/// Example:
///
/// ```moonbit
/// let time = Ptime::of_seconds(1640995200L)
/// inspect(time.seconds(), content="1640995200")
/// inspect(time.picoseconds(), content="0")
/// ```
///
pub fn Ptime::of_seconds(s : Int64) -> Ptime {
  { seconds: s, picoseconds: 0L }
}

///|
/// Normalizes Ptime, ensuring picoseconds are within valid range
fn Ptime::normalize(self : Ptime) -> Ptime {
  if self.picoseconds >= ps_per_s {
    let extra_seconds = self.picoseconds / ps_per_s
    {
      seconds: self.seconds + extra_seconds,
      picoseconds: self.picoseconds % ps_per_s,
    }
  } else if self.picoseconds < 0L {
    let borrow_seconds = (-self.picoseconds + ps_per_s - 1L) / ps_per_s
    {
      seconds: self.seconds - borrow_seconds,
      picoseconds: self.picoseconds + borrow_seconds * ps_per_s,
    }
  } else {
    self
  }
}

///| Ptime Conversion

///|
/// Converts the time point to a floating-point number representing seconds since epoch.
///
/// Parameters:
///
/// * `self` : The time point to convert.
///
/// Returns the time as a `Double` value, combining both seconds and picoseconds components.
///
/// Example:
///
/// ```moonbit
/// let time = Ptime::of_seconds(1640995200L)
/// inspect(time.to_float(), content="1640995200")
/// ```
///
pub fn Ptime::to_float(self : Ptime) -> Double {
  self.seconds.to_double() + self.picoseconds.to_double() / ps_per_s.to_double()
}

///|
/// Returns the seconds component of the time point.
///
/// Parameters:
///
/// * `self` : The time point to query.
///
/// Returns the number of seconds since epoch as an `Int64`.
///
/// Example:
///
/// ```moonbit
/// let time = Ptime::of_seconds(1640995200L)
/// inspect(time.seconds(), content="1640995200")
/// ```
///
pub fn Ptime::seconds(self : Ptime) -> Int64 {
  self.seconds
}

///|
/// Returns the picoseconds component of the time point.
///
/// Parameters:
///
/// * `self` : The time point to query.
///
/// Returns the picoseconds component as an `Int64`, in the range [0, 999_999_999_999].
///
/// Example:
///
/// ```moonbit
/// let time = Ptime::of_float(1640995200.123)
/// inspect(time.unwrap().picoseconds() > 0L, content="true")
/// ```
///
pub fn Ptime::picoseconds(self : Ptime) -> Int64 {
  self.picoseconds
}

///| Span Construction

///|
/// Creates a zero duration span.
///
/// Returns a `Span` representing zero duration with both seconds and picoseconds set to zero.
///
/// Example:
///
/// ```moonbit
/// let zero = Span::zero()
/// inspect(zero.is_zero(), content="true")
/// inspect(zero.seconds(), content="0")
/// ```
///
pub fn Span::zero() -> Span {
  { seconds: 0L, picoseconds: 0L }
}

///|
/// Creates a time span from a floating-point number representing duration in seconds.
///
/// Parameters:
///
/// * `f` : The duration in seconds as a `Double`.
///
/// Returns `Some(Span)` if the input is valid, `None` if the input is NaN or infinite.
/// The fractional part is converted to picoseconds with appropriate precision.
///
/// Example:
///
/// ```moonbit
/// let span = Span::of_float(1.5)
/// inspect(span.unwrap().seconds(), content="1")
/// ```
///
pub fn Span::of_float(f : Double) -> Span? {
  if f.is_nan() || f.is_inf() {
    None
  } else {
    let seconds = f.floor().to_int64()
    let frac = f - f.floor()
    let picoseconds = (frac * ps_per_s.to_double()).to_int64()
    Some(Span::normalize({ seconds, picoseconds }))
  }
}

///|
/// Creates a time span from an integer number of seconds.
///
/// Parameters:
///
/// * `s` : The duration in seconds as an `Int64`.
///
/// Returns a `Span` with the specified seconds and zero picoseconds.
///
/// Example:
///
/// ```moonbit
/// let hour = Span::of_seconds(3600L)
/// inspect(hour.seconds(), content="3600")
/// inspect(hour.picoseconds(), content="0")
/// ```
///
pub fn Span::of_seconds(s : Int64) -> Span {
  { seconds: s, picoseconds: 0L }
}

///|
/// Creates a time span from a number of milliseconds.
///
/// Parameters:
///
/// * `ms` : The duration in milliseconds as an `Int64`.
///
/// Returns a `Span` with the duration converted from milliseconds to seconds and picoseconds.
///
/// Example:
///
/// ```moonbit
/// let span = Span::of_ms(1500L)
/// inspect(span.seconds(), content="1")
/// inspect(span.to_float(), content="1.5")
/// ```
///
pub fn Span::of_ms(ms : Int64) -> Span {
  let seconds = ms / 1000L
  let remainder_ms = ms % 1000L
  let picoseconds = remainder_ms * 1_000_000_000L
  Span::normalize({ seconds, picoseconds })
}

///|
/// Normalizes Span
fn Span::normalize(self : Span) -> Span {
  if self.seconds >= 0L && self.picoseconds >= 0L {
    // Both positive, normalize carry
    if self.picoseconds >= ps_per_s {
      let extra_seconds = self.picoseconds / ps_per_s
      {
        seconds: self.seconds + extra_seconds,
        picoseconds: self.picoseconds % ps_per_s,
      }
    } else {
      self
    }
  } else if self.seconds < 0L && self.picoseconds <= 0L {
    // Both negative, normalize borrow
    if self.picoseconds <= -ps_per_s {
      let borrow_seconds = (-self.picoseconds + ps_per_s - 1L) / ps_per_s
      {
        seconds: self.seconds - borrow_seconds,
        picoseconds: self.picoseconds + borrow_seconds * ps_per_s,
      }
    } else {
      self
    }
    // Different signs, need adjustment
  } else if self.seconds < 0L && self.picoseconds > 0L {
    { seconds: self.seconds + 1L, picoseconds: self.picoseconds - ps_per_s }
  } else if self.seconds > 0L && self.picoseconds < 0L {
    { seconds: self.seconds - 1L, picoseconds: self.picoseconds + ps_per_s }
  } else {
    self
  }
}

///| Span Conversion

///|
/// Converts the time span to a floating-point number representing duration in seconds.
///
/// Parameters:
///
/// * `self` : The time span to convert.
///
/// Returns the duration as a `Double` value, combining both seconds and picoseconds components.
///
/// Example:
///
/// ```moonbit
/// let span = Span::of_ms(1500L)
/// inspect(span.to_float(), content="1.5")
/// ```
///
pub fn Span::to_float(self : Span) -> Double {
  self.seconds.to_double() + self.picoseconds.to_double() / ps_per_s.to_double()
}

///|
/// Returns the seconds component of the time span.
///
/// Parameters:
///
/// * `self` : The time span to query.
///
/// Returns the number of seconds as an `Int64`. Can be negative for backward durations.
///
/// Example:
///
/// ```moonbit
/// let span = Span::of_seconds(3600L)
/// inspect(span.seconds(), content="3600")
/// ```
///
pub fn Span::seconds(self : Span) -> Int64 {
  self.seconds
}

///|
/// Returns the picoseconds component of the time span.
///
/// Parameters:
///
/// * `self` : The time span to query.
///
/// Returns the picoseconds component as an `Int64`, in the range [-999_999_999_999, 999_999_999_999].
///
/// Example:
///
/// ```moonbit
/// let span = Span::of_ms(1500L)
/// inspect(span.picoseconds(), content="500000000000")
/// ```
///
pub fn Span::picoseconds(self : Span) -> Int64 {
  self.picoseconds
}

///| Time Arithmetic

///|
/// Adds a time span to the time point.
///
/// Parameters:
///
/// * `self` : The time point to add to.
/// * `span` : The time span to add.
///
/// Returns a new `Ptime` representing the result of adding the span to the time point.
///
/// Example:
///
/// ```moonbit
/// let time = Ptime::epoch()
/// let hour = Span::of_seconds(3600L)
/// let later = time.add_span(hour)
/// inspect(later.seconds(), content="3600")
/// ```
///
pub fn Ptime::add_span(self : Ptime, span : Span) -> Ptime {
  let new_ptime : Ptime = {
    seconds: self.seconds + span.seconds,
    picoseconds: self.picoseconds + span.picoseconds,
  }
  Ptime::normalize(new_ptime)
}

///|
/// Subtracts a time span from the time point.
///
/// Parameters:
///
/// * `self` : The time point to subtract from.
/// * `span` : The time span to subtract.
///
/// Returns a new `Ptime` representing the result of subtracting the span from the time point.
///
/// Example:
///
/// ```moonbit
/// let time = Ptime::of_seconds(3600L)
/// let hour = Span::of_seconds(3600L)
/// let earlier = time.sub_span(hour)
/// inspect(earlier.seconds(), content="0")
/// ```
///
pub fn Ptime::sub_span(self : Ptime, span : Span) -> Ptime {
  let neg_span = Span::neg(span)
  self.add_span(neg_span)
}

///|
/// Calculates the difference between two time points.
///
/// Parameters:
///
/// * `self` : The later time point.
/// * `other` : The earlier time point to subtract from.
///
/// Returns a `Span` representing the duration from `other` to `self`.
/// The result is positive if `self` is later than `other`, negative otherwise.
///
/// Example:
///
/// ```moonbit
/// let t1 = Ptime::of_seconds(1000L)
/// let t2 = Ptime::of_seconds(2000L)
/// let diff = t2.diff(t1)
/// inspect(diff.seconds(), content="1000")
/// ```
///
pub fn Ptime::diff(self : Ptime, other : Ptime) -> Span {
  let span : Span = {
    seconds: self.seconds - other.seconds,
    picoseconds: self.picoseconds - other.picoseconds,
  }
  Span::normalize(span)
}

///| Span Arithmetic

///|
/// Adds two time spans together.
///
/// Parameters:
///
/// * `self` : The first time span.
/// * `other` : The second time span to add.
///
/// Returns a new `Span` representing the sum of the two spans.
///
/// Example:
///
/// ```moonbit
/// let span1 = Span::of_seconds(3600L)
/// let span2 = Span::of_seconds(1800L)
/// let sum = span1.add(span2)
/// inspect(sum.seconds(), content="5400")
/// ```
///
pub fn Span::add(self : Span, other : Span) -> Span {
  let span : Span = {
    seconds: self.seconds + other.seconds,
    picoseconds: self.picoseconds + other.picoseconds,
  }
  Span::normalize(span)
}

///|
/// Subtracts one time span from another.
///
/// Parameters:
///
/// * `self` : The time span to subtract from.
/// * `other` : The time span to subtract.
///
/// Returns a new `Span` representing the difference between the two spans.
///
/// Example:
///
/// ```moonbit
/// let span1 = Span::of_seconds(3600L)
/// let span2 = Span::of_seconds(1800L)
/// let diff = span1.sub(span2)
/// inspect(diff.seconds(), content="1800")
/// ```
///
pub fn Span::sub(self : Span, other : Span) -> Span {
  let span : Span = {
    seconds: self.seconds - other.seconds,
    picoseconds: self.picoseconds - other.picoseconds,
  }
  Span::normalize(span)
}

///|
/// Negates a time span, changing its direction.
///
/// Parameters:
///
/// * `self` : The time span to negate.
///
/// Returns a new `Span` with the opposite direction.
///
/// Example:
///
/// ```moonbit
/// let span = Span::of_seconds(3600L)
/// let neg_span = Span::neg(span)
/// inspect(neg_span.seconds(), content="-3600")
/// ```
///
pub fn Span::neg(self : Span) -> Span {
  { seconds: -self.seconds, picoseconds: -self.picoseconds }
}

///|
/// Multiplies a time span by an integer factor.
///
/// Parameters:
///
/// * `self` : The time span to multiply.
/// * `n` : The integer factor to multiply by.
///
/// Returns a new `Span` representing the scaled duration.
///
/// Example:
///
/// ```moonbit
/// let hour = Span::of_seconds(3600L)
/// let three_hours = hour.mul(3L)
/// inspect(three_hours.seconds(), content="10800")
/// ```
///
pub fn Span::mul(self : Span, n : Int64) -> Span {
  let span : Span = {
    seconds: self.seconds * n,
    picoseconds: self.picoseconds * n,
  }
  Span::normalize(span)
}

///| Comparison

///|
/// Compares two time points.
///
/// Parameters:
///
/// * `self` : The first time point.
/// * `other` : The second time point to compare with.
///
/// Returns `-1` if `self` is earlier than `other`, `1` if later, `0` if equal.
///
/// Example:
///
/// ```moonbit
/// let t1 = Ptime::of_seconds(1000L)
/// let t2 = Ptime::of_seconds(2000L)
/// inspect(t1.compare(t2), content="-1")
/// ```
///
pub fn Ptime::compare(self : Ptime, other : Ptime) -> Int {
  if self.seconds < other.seconds {
    -1
  } else if self.seconds > other.seconds {
    1
    // Seconds equal, compare picoseconds
  } else if self.picoseconds < other.picoseconds {
    -1
  } else if self.picoseconds > other.picoseconds {
    1
  } else {
    0
  }
}

///|
/// Compares two time spans.
///
/// Parameters:
///
/// * `self` : The first time span.
/// * `other` : The second time span to compare with.
///
/// Returns `-1` if `self` is shorter than `other`, `1` if longer, `0` if equal.
///
/// Example:
///
/// ```moonbit
/// let span1 = Span::of_seconds(100L)
/// let span2 = Span::of_seconds(200L)
/// inspect(span1.compare(span2), content="-1")
/// ```
///
pub fn Span::compare(self : Span, other : Span) -> Int {
  if self.seconds < other.seconds {
    -1
  } else if self.seconds > other.seconds {
    1
    // Seconds equal, compare picoseconds
  } else if self.picoseconds < other.picoseconds {
    -1
  } else if self.picoseconds > other.picoseconds {
    1
  } else {
    0
  }
}

///|
/// Checks if the time span represents a positive duration.
///
/// Parameters:
///
/// * `self` : The time span to check.
///
/// Returns `true` if the span is positive (forward in time), `false` otherwise.
///
/// Example:
///
/// ```moonbit
/// let positive = Span::of_seconds(100L)
/// inspect(positive.is_positive(), content="true")
/// ```
///
pub fn Span::is_positive(self : Span) -> Bool {
  self.seconds > 0L || (self.seconds == 0L && self.picoseconds > 0L)
}

///|
/// Checks if the time span represents a negative duration.
///
/// Parameters:
///
/// * `self` : The time span to check.
///
/// Returns `true` if the span is negative (backward in time), `false` otherwise.
///
/// Example:
///
/// ```moonbit
/// let negative = Span::of_seconds(-100L)
/// inspect(negative.is_negative(), content="true")
/// ```
///
pub fn Span::is_negative(self : Span) -> Bool {
  self.seconds < 0L || (self.seconds == 0L && self.picoseconds < 0L)
}

///|
/// Checks if the time span represents zero duration.
///
/// Parameters:
///
/// * `self` : The time span to check.
///
/// Returns `true` if the span is exactly zero, `false` otherwise.
///
/// Example:
///
/// ```moonbit
/// let zero = Span::zero()
/// inspect(zero.is_zero(), content="true")
/// ```
///
pub fn Span::is_zero(self : Span) -> Bool {
  self.seconds == 0L && self.picoseconds == 0L
}

///| Date/Time Utilities

///|
/// Determines if a year is a leap year
fn is_leap_year(year : Int) -> Bool {
  year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)
}

///|
/// Gets the number of days in a specified year and month
fn days_in_month(year : Int, month : Int) -> Int {
  match month {
    1 | 3 | 5 | 7 | 8 | 10 | 12 => 31
    4 | 6 | 9 | 11 => 30
    2 => if is_leap_year(year) { 29 } else { 28 }
    _ => 0 // Invalid month
  }
}

///|
/// Calculates the number of days from POSIX epoch to the specified date
fn days_since_epoch(year : Int, month : Int, day : Int) -> Int64 {
  let epoch_year = 1970

  // Calculate year difference
  let mut total_days = 0L
  if year >= epoch_year {
    // Forward calculation
    for y = epoch_year; y < year; y = y + 1 {
      let days_in_year = if is_leap_year(y) { 366L } else { 365L }
      total_days = total_days + days_in_year
    } else {
      ()
    }
  } else {
    // Backward calculation
    for y = epoch_year - 1; y >= year; y = y - 1 {
      let days_in_year = if is_leap_year(y) { 366L } else { 365L }
      total_days = total_days - days_in_year
    } else {
      ()
    }
  }

  // Calculate month difference
  for m = 1; m < month; m = m + 1 {
    total_days = total_days + days_in_month(year, m).to_int64()
  } else {
    ()
  }

  // Add days (subtract 1 because day starts from 1)
  total_days + (day - 1).to_int64()
}

///|
/// Converts days to year, month, day - simplified implementation
fn days_to_ymd(days : Int64) -> (Int, Int, Int) {
  // Simplified implementation, returns a basic date
  // A more complex algorithm is needed to correctly calculate year, month, day
  let epoch_year = 1970
  let days_per_year = 365L
  let estimated_year = epoch_year + (days / days_per_year).to_int()
  (estimated_year, 1, 1) // Temporary implementation
}

///| RFC 3339 Support - Simplified Implementation

///|
/// Converts the time point to an RFC 3339 formatted string (UTC timezone).
///
/// Parameters:
///
/// * `self` : The time point to format.
///
/// Returns a string in RFC 3339 format (YYYY-MM-DDTHH:MM:SSZ).
///
/// Example:
///
/// ```moonbit
/// let epoch = Ptime::epoch()
/// inspect(epoch.to_rfc3339(), content="1970-01-01T00:00:00Z")
/// ```
///
pub fn Ptime::to_rfc3339(self : Ptime) -> String {
  // Calculate days and seconds within day
  let mut remaining_seconds = self.seconds
  let mut days = 0L

  // Handle negative case
  if remaining_seconds < 0L {
    days = remaining_seconds / 86400L - 1L
    remaining_seconds = remaining_seconds - days * 86400L
  } else {
    days = remaining_seconds / 86400L
    remaining_seconds = remaining_seconds % 86400L
  }
  let (year, month, day) = days_to_ymd(days)
  let hour = (remaining_seconds / 3600L).to_int()
  let minute = (remaining_seconds % 3600L / 60L).to_int()
  let second = (remaining_seconds % 60L).to_int()

  // Format string
  let year_str = year.to_string()
  let month_str = if month < 10 {
    "0" + month.to_string()
  } else {
    month.to_string()
  }
  let day_str = if day < 10 { "0" + day.to_string() } else { day.to_string() }
  let hour_str = if hour < 10 {
    "0" + hour.to_string()
  } else {
    hour.to_string()
  }
  let minute_str = if minute < 10 {
    "0" + minute.to_string()
  } else {
    minute.to_string()
  }
  let second_str = if second < 10 {
    "0" + second.to_string()
  } else {
    second.to_string()
  }
  year_str +
  "-" +
  month_str +
  "-" +
  day_str +
  "T" +
  hour_str +
  ":" +
  minute_str +
  ":" +
  second_str +
  "Z"
}

///|
/// Creates a time point from specific year, month, day, hour, minute, and second (UTC).
///
/// Parameters:
///
/// * `year` : The year (can be negative for BCE years).
/// * `month` : The month (1-12).
/// * `day` : The day of month (1-31, depending on month).
/// * `hour` : The hour (0-23).
/// * `minute` : The minute (0-59).
/// * `second` : The second (0-59).
///
/// Returns `Some(Ptime)` if the date/time is valid, `None` otherwise.
///
/// Example:
///
/// ```moonbit
/// let time = Ptime::of_ymd_hms(2022, 1, 1, 12, 0, 0)
/// inspect(time is Some(_), content="true")
/// ```
///
pub fn Ptime::of_ymd_hms(
  year : Int,
  month : Int,
  day : Int,
  hour : Int,
  minute : Int,
  second : Int,
) -> Ptime? {
  // Validate input
  if month < 1 ||
    month > 12 ||
    day < 1 ||
    day > days_in_month(year, month) ||
    hour < 0 ||
    hour > 23 ||
    minute < 0 ||
    minute > 59 ||
    second < 0 ||
    second > 59 {
    return None
  }

  // Calculate POSIX timestamp
  let days = days_since_epoch(year, month, day)
  let seconds_in_day = hour.to_int64() * 3600L +
    minute.to_int64() * 60L +
    second.to_int64()
  let total_seconds = days * 86400L + seconds_in_day
  Some({ seconds: total_seconds, picoseconds: 0L })
}
