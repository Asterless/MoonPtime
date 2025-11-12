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
