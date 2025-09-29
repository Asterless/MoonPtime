# MoonPtime - POSIX Time Library for MoonBit

A lightweight, high-precision time handling library for MoonBit, focused on POSIX timestamps and time spans with picosecond accuracy.

## What is Ptime?

Ptime is a time library that deals with **time points** and **time spans** rather than complex calendars and timezones. It provides:

- **High precision** - Picosecond-level accuracy (12 decimal places)
- **Simple API** - Focus on time points and durations
- **POSIX compliant** - Uses standard Unix timestamps
- **RFC 3339 support** - Standard time string formatting
- **Pure MoonBit** - No external dependencies

## Features

- ✅ POSIX time representation (seconds since 1970-01-01 00:00:00 UTC)
- ✅ Picosecond precision for sub-second accuracy
- ✅ Time point arithmetic (add/subtract spans)
- ✅ Time span operations (add, subtract, multiply, compare)
- ✅ RFC 3339 string formatting (`2025-01-01T12:00:00Z`)
- ✅ Floating-point conversions
- ✅ Comprehensive comparison operations
- ✅ Robust normalization and validation
- ✅ Clean, ergonomic API

## Usage

### Basic Usage

```moonbit
// Create time points
let epoch = @ptime.Ptime::epoch()
let now = @ptime.Ptime::of_float(1640995200.0) // 2022-01-01 00:00:00 UTC
let specific_time = @ptime.Ptime::of_ymd_hms(2025, 8, 22, 15, 30, 45)

// Create time spans
let one_hour = @ptime.Span::of_seconds(3600L)
let half_second = @ptime.Span::of_ms(500L)

// Time arithmetic
let later = now.unwrap().add_span(one_hour)
let duration = later.diff(now.unwrap())

// RFC 3339 formatting
let time_string = later.to_rfc3339() // "2022-01-01T01:00:00Z"
```

### API Reference

#### Core Types

- **`Ptime`** - Represents a point in time since POSIX epoch with picosecond precision
- **`Span`** - Represents a duration/time span, can be positive or negative

#### Time Point Functions

- `Ptime::epoch() -> Ptime` - Create POSIX epoch (1970-01-01 00:00:00 UTC)
- `Ptime::of_float(seconds: Double) -> Ptime?` - Create from floating-point seconds
- `Ptime::of_seconds(seconds: Int64) -> Ptime` - Create from integer seconds
- `Ptime::of_ymd_hms(year, month, day, hour, minute, second) -> Ptime?` - Create from date/time components
- `to_float(self) -> Double` - Convert to floating-point seconds
- `to_rfc3339(self) -> String` - Format as RFC 3339 string
- `seconds(self) -> Int64` - Get seconds component
- `picoseconds(self) -> Int64` - Get picoseconds component

#### Time Arithmetic

- `add_span(self, span: Span) -> Ptime` - Add a time span to a time point
- `sub_span(self, span: Span) -> Ptime` - Subtract a time span from a time point
- `diff(self, other: Ptime) -> Span` - Calculate difference between two time points
- `compare(self, other: Ptime) -> Int` - Compare two time points (-1, 0, 1)

#### Time Span Functions

- `Span::zero() -> Span` - Create zero duration
- `Span::of_float(seconds: Double) -> Span?` - Create from floating-point seconds
- `Span::of_seconds(seconds: Int64) -> Span` - Create from integer seconds
- `Span::of_ms(milliseconds: Int64) -> Span` - Create from milliseconds
- `add(self, other: Span) -> Span` - Add two spans
- `sub(self, other: Span) -> Span` - Subtract spans
- `mul(self, factor: Int64) -> Span` - Multiply span by integer
- `neg(self) -> Span` - Negate span (change direction)

#### Span Properties

- `is_positive(self) -> Bool` - Check if span is positive
- `is_negative(self) -> Bool` - Check if span is negative  
- `is_zero(self) -> Bool` - Check if span is zero
- `compare(self, other: Span) -> Int` - Compare two spans

## Examples

See `src/example.mbt` for comprehensive examples including:

- Basic time point creation and conversion
- Time span operations and arithmetic
- Time point arithmetic and calculations
- Time comparison operations
- Precision demonstrations
- RFC 3339 formatting

## RFC 3339 Support

The library provides RFC 3339 compliant string formatting:

- **Format**: `YYYY-MM-DDTHH:MM:SSZ` (UTC timezone)
- **Example**: `2025-08-22T15:30:45Z`
- **Precision**: Currently supports second-level precision in string output

## Precision

MoonPtime uses a `(seconds, picoseconds)` representation:

- **Seconds**: Int64 - Can represent dates far into past and future
- **Picoseconds**: Int64 - Provides 12 decimal places of sub-second precision
- **Range**: Effectively unlimited for practical applications
- **Accuracy**: Suitable for high-precision timing, logging, and scientific applications

## Testing

Run the test suite:

```bash
moon test
```

The test suite includes:

- Time point creation and conversion tests
- Time span arithmetic verification
- Time comparison accuracy tests  
- RFC 3339 formatting validation
- Edge case and boundary condition tests
- Precision and normalization tests

## Performance

The implementation is optimized for:

- **Minimal allocations** - Efficient memory usage
- **Fast arithmetic** - Optimized time calculations  
- **Compact representation** - Two Int64 values per time point
- **Normalized operations** - Automatic overflow/underflow handling

## Project Structure

```text
MoonPtime/
├── src/                    # Source code
│   ├── MoonPtime.mbt      # Core library implementation
│   ├── MoonPtime_test.mbt # Comprehensive test suite
│   ├── example.mbt        # Usage examples
│   └── moon.pkg.json      # Package configuration
├── cmd/main/              # Demo application
├── moon.mod.json          # Module configuration
└── README.md              # This file
```

## License

Licensed under the Apache License 2.0. See `LICENSE` file for details.

## Contributing

Contributions are welcome! Please ensure:

- Code follows MoonBit style guidelines
- All tests pass and new functionality includes tests
- Performance is maintained or improved
- Documentation is updated for new features
- POSIX time semantics are preserved

## Similar Libraries

This library is inspired by:

- [OCaml Ptime](https://erratique.ch/software/ptime) - The original Ptime library
- [Rust chrono](https://github.com/chronotope/chrono) - Comprehensive date/time library
- [Go time](https://pkg.go.dev/time) - Standard library time package

## FAQ

**Q: Why not support timezones?**  
A: MoonPtime focuses on absolute time points (UTC) and durations. For timezone-aware operations, use this library as a foundation and add timezone logic on top.

**Q: Why picosecond precision?**  
A: Provides future-proof precision for high-resolution timing, scientific applications, and avoids precision loss in calculations.

**Q: Is this suitable for embedded systems?**  
A: Yes, the library has minimal dependencies and efficient representation, making it suitable for resource-constrained environments.
