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
const PS_PER_S : Int64 = 1_000_000_000_000L
