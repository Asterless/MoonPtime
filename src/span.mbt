///|
/// Creates a zero duration span.
/// 
/// Returns a `Span` representing a zero duration.
/// 
/// Example:
///
/// ```moonbit
/// let zero_span = Span::zero()
/// inspect(zero_span.get_seconds(), content="0")
/// ```
pub fn Span::zero() -> Span {
  { seconds: 0L, picoseconds: 0L }
}

///|
/// Creates a time span from a floating-point number representing duration in seconds.
/// 
/// Parameters:
/// 
/// * `f` : The duration in seconds as a floating-point number.
/// 
/// Returns a `Span` representing the specified duration, or `None` if the input is not a valid number.
pub fn Span::of_float(f : Double) -> Span? {
  if f.is_nan() || f.is_inf() {
    None
  } else {
    let seconds = f.floor().to_int64()
    let frac = f - f.floor()
    let picoseconds = (frac * PS_PER_S.to_double()).to_int64()
    Some(Span::normalize({ seconds, picoseconds }))
  }
}

///|
/// Creates a time span from an integer number of seconds.
/// 
/// Parameters:
/// 
/// * `s` : The duration in seconds as an integer.
/// 
/// Returns a `Span` representing the specified duration.
/// 
/// Example:
///
/// ```moonbit
/// let span = Span::of_seconds(60L)
/// inspect(span.get_seconds(), content="60")
/// ```
pub fn Span::of_seconds(s : Int64) -> Span {
  { seconds: s, picoseconds: 0L }
}

///|
/// Creates a time span from a number of milliseconds.
/// 
/// Parameters:
/// 
/// * `ms` : The duration in milliseconds as an integer.
/// 
/// Returns a `Span` representing the specified duration.
/// 
/// Example:
///
/// ```moonbit
/// let span = Span::of_ms(1500L)
/// inspect(span.get_seconds(), content="1")
/// inspect(span.get_picoseconds(), content="500000000000")
/// ```
pub fn Span::of_ms(ms : Int64) -> Span {
  let seconds = ms / 1000L
  let remainder_ms = ms % 1000L
  let picoseconds = remainder_ms * 1_000_000_000L
  Span::normalize({ seconds, picoseconds })
}

///|
/// Normalizes a `Span` to ensure that the picoseconds part is within the valid range.
/// 
/// Parameters:
/// 
/// * `self` : The original `Span` to normalize.
/// 
/// Returns a normalized `Span` with picoseconds adjusted to be within the valid range.
fn Span::normalize(self : Span) -> Span {
  if self.seconds >= 0L && self.picoseconds >= 0L {
    // Both positive, normalize carry
    if self.picoseconds >= PS_PER_S {
      let extra_seconds = self.picoseconds / PS_PER_S
      {
        seconds: self.seconds + extra_seconds,
        picoseconds: self.picoseconds % PS_PER_S,
      }
    } else {
      self
    }
  } else if self.seconds < 0L && self.picoseconds <= 0L {
    // Both negative, normalize borrow
    if self.picoseconds <= -PS_PER_S {
      let borrow_seconds = (-self.picoseconds + PS_PER_S - 1L) / PS_PER_S
      {
        seconds: self.seconds - borrow_seconds,
        picoseconds: self.picoseconds + borrow_seconds * PS_PER_S,
      }
    } else {
      self
    }
    // Different signs, need adjustment
  } else if self.seconds < 0L && self.picoseconds > 0L {
    { seconds: self.seconds + 1L, picoseconds: self.picoseconds - PS_PER_S }
  } else if self.seconds > 0L && self.picoseconds < 0L {
    { seconds: self.seconds - 1L, picoseconds: self.picoseconds + PS_PER_S }
  } else {
    self
  }
}

///|
/// Converts the time span to a floating-point number representing duration in seconds.
/// 
/// Parameters:
/// 
/// * `self` : The `Span` instance.
/// 
/// Returns a `Double` representing the duration in seconds.
/// 
/// Example:
///
/// ```moonbit
/// let span = Span::of_seconds(1L)
/// inspect(span.to_float(), content="1")
/// ```
pub fn Span::to_float(self : Span) -> Double {
  self.seconds.to_double() + self.picoseconds.to_double() / PS_PER_S.to_double()
}

///|
/// Returns the seconds component of the time span.
/// 
/// Parameters:
/// 
/// * `self` : The `Span` instance.
/// 
/// Returns the seconds part of the time span.
/// 
/// Example:
///
/// ```moonbit
/// let span = Span::of_seconds(60L)
/// inspect(span.get_seconds(), content="60")
/// ```
pub fn Span::get_seconds(self : Span) -> Int64 {
  self.seconds
}

///|
/// Returns the picoseconds component of the time span.
/// 
/// Parameters:
/// 
/// * `self` : The `Span` instance.
/// 
/// Returns the picoseconds part of the time span.
/// 
/// Example:
///
/// ```moonbit
/// let span = Span::of_seconds(60L)
/// inspect(span.get_picoseconds(), content="0")
/// ```
pub fn Span::get_picoseconds(self : Span) -> Int64 {
  self.picoseconds
}

///|
/// Adds two time spans together.
/// 
/// Parameters:
/// 
/// * `self` : The first `Span` instance.
/// * `other` : The second `Span` instance.
/// 
/// Returns a new `Span` representing the sum of the two spans.
/// 
/// Example:
///
/// ```moonbit
/// let span1 = Span::of_seconds(60L)
/// let span2 = Span::of_seconds(30L)
/// let result = span1 + span2
/// inspect(result.get_seconds(), content="90")
/// ```
pub impl Add for Span with add(self : Span, other : Span) -> Span {
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
/// * `self` : The first `Span` instance.
/// * `other` : The second `Span` instance.
/// 
/// Returns a new `Span` representing the difference of the two spans.
/// 
/// Example:
///
/// ```moonbit
/// let span1 = Span::of_seconds(60L)
/// let span2 = Span::of_seconds(30L)
/// let result = span1 - span2
/// inspect(result.get_seconds(), content="30")
/// ```
pub impl Sub for Span with sub(self : Span, other : Span) -> Span {
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
/// * `self` : The `Span` instance.
/// 
/// Returns a new `Span` representing the negated time span.
/// 
/// Example:
///
/// ```moonbit
/// let span = Span::of_seconds(60L)
/// let negated = -span
/// inspect(negated.get_seconds(), content="-60")
/// ```
pub impl Neg for Span with neg(self : Span) -> Span {
  { seconds: -self.seconds, picoseconds: -self.picoseconds }
}

///|
/// Multiplies a time span by an integer factor.
pub fn Span::scalar(self : Span, n : Int64) -> Span {
  let span : Span = {
    seconds: self.seconds * n,
    picoseconds: self.picoseconds * n,
  }
  Span::normalize(span)
}

///|
/// Compares two time spans.
/// 
/// Parameters:
/// 
/// * `self` : The first `Span` instance.
/// * `other` : The second `Span` instance.
/// 
/// Returns an `Int` indicating the comparison result (-1 if less, 1 if greater, 0 if equal).
/// 
/// Example:
///
/// ```moonbit
/// let span1 = Span::of_seconds(60L)
/// let span2 = Span::of_seconds(30L)
/// let result = span1.compare(span2)
/// inspect(result, content="1")
/// ```
pub impl Compare for Span with compare(self : Span, other : Span) -> Int {
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
/// * `self` : The `Span` instance.
/// 
/// Returns `true` if the time span is positive, otherwise `false`.
/// 
/// Example:
///
/// ```moonbit
/// let span = Span::of_seconds(60L)
/// inspect(span.is_positive(), content="true")
/// ```
pub fn Span::is_positive(self : Span) -> Bool {
  self.seconds > 0L || (self.seconds == 0L && self.picoseconds > 0L)
}

///|
/// Checks if the time span represents a negative duration.
/// 
/// Parameters:
/// 
/// * `self` : The `Span` instance.
/// 
/// Returns `true` if the time span is negative, otherwise `false`.
/// 
/// Example:
///
/// ```moonbit
/// let span = Span::of_seconds(60L)
/// inspect(span.is_negative(), content="false")
/// ```
pub fn Span::is_negative(self : Span) -> Bool {
  self.seconds < 0L || (self.seconds == 0L && self.picoseconds < 0L)
}

///|
/// Checks if the time span represents zero duration.
/// 
/// Parameters:
/// 
/// * `self` : The `Span` instance.
/// 
/// Returns `true` if the time span is zero, otherwise `false`.
/// 
/// Example:
///
/// ```moonbit
/// let span = Span::of_seconds(0L)
/// inspect(span.is_zero(), content="true")
/// ```
pub fn Span::is_zero(self : Span) -> Bool {
  self.seconds == 0L && self.picoseconds == 0L
}
