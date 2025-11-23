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
  let y = year.to_int64()
  let d = day.to_int64()

  // Calculate days from years (optimized)
  // Days in previous years = 365 * (y-1) + leaps
  let count_leaps = fn(yr : Int64) -> Int64 { yr / 4L - yr / 100L + yr / 400L }
  let days_from_years = (y - 1970L) * 365L +
    (count_leaps(y - 1L) - count_leaps(1969L))

  // Calculate month difference
  let mut days_from_months = 0L
  for i = 1; i < month; i = i + 1 {
    days_from_months = days_from_months + days_in_month(year, i).to_int64()
  }

  // Add days (subtract 1 because day starts from 1)
  days_from_years + days_from_months + (d - 1L)
}

///|
/// Converts days to year, month, day using efficient civil time algorithm
fn days_to_ymd(days : Int64) -> (Int, Int, Int) {
  // Shift to 0000-03-01 epoch (719468 days before 1970-01-01)
  let z = days + 719468L
  let era = if z >= 0L { z / 146097L } else { (z - 146096L) / 146097L }
  let doe = z - era * 146097L
  let yoe = (doe - doe / 1460L + doe / 36524L - doe / 146096L) / 365L
  let y = yoe + era * 400L
  let doy = doe - (365L * yoe + yoe / 4L - yoe / 100L)
  let mp = (5L * doy + 2L) / 153L
  let d = doy - (153L * mp + 2L) / 5L + 1L
  let m = if mp < 10L { mp + 3L } else { mp - 9L }
  let year = if m <= 2L { y + 1L } else { y }
  (year.to_int(), m.to_int(), d.to_int())
}

///| RFC 3339 Support - Simplified Implementation

///|
/// Converts the time point to an RFC 3339 formatted string (UTC timezone).
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
