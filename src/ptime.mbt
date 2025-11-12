///|
/// Creates a time point representing the POSIX epoch (1970-01-01 00:00:00 UTC).
///
/// Returns a `Ptime` representing the Unix epoch with both seconds and picoseconds set to zero.
///
/// Example:
///
/// ```moonbit
/// let epoch = Ptime::epoch()
/// inspect(epoch.get_seconds(), content="0")
/// inspect(epoch.get_picoseconds(), content="0")
/// ```
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
/// inspect(time.unwrap().get_seconds(), content="1640995200")
/// ```
pub fn Ptime::of_float(f : Double) -> Ptime? {
  if f.is_nan() || f.is_inf() {
    None
  } else {
    let seconds = f.floor().to_int64()
    let frac = f - f.floor()
    let picoseconds = (frac * PS_PER_S.to_double()).to_int64()
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
/// inspect(time.get_seconds(), content="1640995200")
/// inspect(time.get_picoseconds(), content="0")
/// ```
pub fn Ptime::of_seconds(s : Int64) -> Ptime {
  { seconds: s, picoseconds: 0L }
}

///|
/// Normalizes Ptime, ensuring picoseconds are within valid range
fn Ptime::normalize(self : Ptime) -> Ptime {
  if self.picoseconds >= PS_PER_S {
    let extra_seconds = self.picoseconds / PS_PER_S
    {
      seconds: self.seconds + extra_seconds,
      picoseconds: self.picoseconds % PS_PER_S,
    }
  } else if self.picoseconds < 0L {
    let borrow_seconds = (-self.picoseconds + PS_PER_S - 1L) / PS_PER_S
    {
      seconds: self.seconds - borrow_seconds,
      picoseconds: self.picoseconds + borrow_seconds * PS_PER_S,
    }
  } else {
    self
  }
}

///|
/// Adds a time span to the time point.
/// 
/// Parameters:
/// 
/// * `self` : The original time point.
/// * `span` : The time span to add. 
/// 
/// Returns a new `Ptime` representing the result of adding the time span to the original time point.
///
/// Example:
///
/// ```moonbit
/// let time = Ptime::epoch()
/// let span = Span::of_seconds(60L)
/// let new_time = time.add_span(span)
/// inspect(new_time.get_seconds(), content="60")
/// ```
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
/// * `self` : The original time point.
/// * `span` : The time span to subtract. 
/// 
/// Returns a new `Ptime` representing the result of subtracting the time span from the original time point.
///
/// Example:
///
/// ```moonbit
/// let time = Ptime::epoch()
/// let span = Span::of_seconds(60L)
/// let new_time = time.sub_span(span)
/// inspect(new_time.get_seconds(), content="-60")
/// ```
pub fn Ptime::sub_span(self : Ptime, span : Span) -> Ptime {
  let neg_span = -span
  self.add_span(neg_span)
}

///|
/// Calculates the difference between two time points.
/// 
/// Parameters:
///
/// * `self` : The first time point.
/// * `other` : The second time point.
///
/// Returns a `Span` representing the difference between the two time points.
///
/// Example:
///
/// ```moonbit
/// let time1 = Ptime::of_seconds(100L)
/// let time2 = Ptime::of_seconds(60L)
/// let diff = time1.diff(time2)
/// inspect(diff.get_seconds(), content="40")
/// ```
pub fn Ptime::diff(self : Ptime, other : Ptime) -> Span {
  let span : Span = {
    seconds: self.seconds - other.seconds,
    picoseconds: self.picoseconds - other.picoseconds,
  }
  Span::normalize(span)
}

///|
pub impl Compare for Ptime with compare(self : Ptime, other : Ptime) -> Int {
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
pub impl Compare for Ptime with op_gt(self : Ptime, other : Ptime) -> Bool {
  self.compare(other) > 0
}

///|
pub impl Compare for Ptime with op_lt(self : Ptime, other : Ptime) -> Bool {
  self.compare(other) < 0
}

///|
pub impl Compare for Ptime with op_ge(self : Ptime, other : Ptime) -> Bool {
  self.compare(other) >= 0
}

///|
pub impl Compare for Ptime with op_le(self : Ptime, other : Ptime) -> Bool {
  self.compare(other) <= 0
}

///| Ptime Conversion

///|
/// Converts the time point to a floating-point number representing seconds since epoch.
/// 
/// Parameters:
///
/// * `self` : The time point to convert.
///
/// Returns a `Double` representing the time in seconds since the POSIX epoch.
///
/// Example:
///
/// ```moonbit
/// let time = Ptime::epoch()
/// inspect(time.to_float(), content="0")
/// ```
pub fn Ptime::to_float(self : Ptime) -> Double {
  self.seconds.to_double() + self.picoseconds.to_double() / PS_PER_S.to_double()
}

///|
/// Returns the seconds component of the time point.
/// 
/// Parameters:
///
/// * `self` : The time point from which to get the seconds component.
///
/// Returns an `Int64` representing the seconds component of the time point.
///
/// Example:
///
/// ```moonbit
/// let time = Ptime::epoch()
/// inspect(time.get_seconds(), content="0")
/// ```
pub fn Ptime::get_seconds(self : Ptime) -> Int64 {
  self.seconds
}

///|
/// Returns the picoseconds component of the time point.
/// 
/// Parameters:
///
/// * `self` : The time point from which to get the picoseconds component.
///
/// Returns an `Int64` representing the picoseconds component of the time point.
///
/// Example:
///
/// ```moonbit
/// let time = Ptime::epoch()
/// inspect(time.get_picoseconds(), content="0")
/// ```
pub fn Ptime::get_picoseconds(self : Ptime) -> Int64 {
  self.picoseconds
}
