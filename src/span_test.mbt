///|
test "span_operations" {
  let span1 = Span::of_seconds(3600L) // 1 hour
  let span2 = Span::of_seconds(1800L) // 30 minutes
  let sum = span1 + span2
  inspect(sum.get_seconds(), content="5400") // 1.5 hours
  let diff = span1 - span2
  inspect(diff.get_seconds(), content="1800") // 30 minutes
  let doubled = span1.scalar(2L)
  inspect(doubled.get_seconds(), content="7200") // 2 hours
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
test "span_of_float" {
  // Normal case
  let s1 = Span::of_float(1.5).unwrap()
  inspect(s1.get_seconds(), content="1")
  inspect(s1.get_picoseconds(), content="500000000000")

  // Negative case
  let s2 = Span::of_float(-1.5).unwrap()
  inspect(s2.get_seconds(), content="-1")
  inspect(s2.get_picoseconds(), content="-500000000000")

  // NaN and Inf
  inspect(Span::of_float(@double.not_a_number), content="None")
  inspect(Span::of_float(@double.infinity), content="None")
}

///|
test "span_of_ms" {
  let s = Span::of_ms(1500L)
  inspect(s.get_seconds(), content="1")
  inspect(s.get_picoseconds(), content="500000000000")
  let s_neg = Span::of_ms(-1500L)
  inspect(s_neg.get_seconds(), content="-1")
  inspect(s_neg.get_picoseconds(), content="-500000000000")
}

///|
test "span_normalization_edge_cases" {
  // Case: seconds > 0, picoseconds < 0 (via subtraction)
  // 2s - 2.5s = -0.5s
  let s1 = Span::of_seconds(2L)
  let s2 = Span::of_ms(2500L) // 2.5s
  let diff = s1 - s2
  inspect(diff.get_seconds(), content="0")
  inspect(diff.get_picoseconds(), content="-500000000000")

  // Case: seconds < 0, picoseconds > 0 (via addition)
  // -2s + 0.5s = -1.5s
  let s3 = Span::of_seconds(-2L)
  let s4 = Span::of_ms(500L)
  let sum = s3 + s4
  inspect(sum.get_seconds(), content="-1")
  inspect(sum.get_picoseconds(), content="-500000000000")
}

///|
test "span_to_float" {
  let s = Span::of_ms(1500L)
  inspect(s.to_float(), content="1.5")
  let s_neg = Span::of_ms(-2500L)
  inspect(s_neg.to_float(), content="-2.5")
}

///|
test "span_compare" {
  let s1 = Span::of_seconds(1L)
  let s2 = Span::of_seconds(2L)
  let s3 = Span::of_seconds(1L)
  inspect(s1 < s2, content="true")
  inspect(s2 > s1, content="true")
  inspect(s1 == s3, content="true")

  // Compare with picoseconds
  let s4 = Span::of_ms(1100L)
  let s5 = Span::of_ms(1200L)
  inspect(s4 < s5, content="true")
}

///|
test "span_neg" {
  let s = Span::of_seconds(1L)
  let neg_s = -s
  inspect(neg_s.get_seconds(), content="-1")
  inspect(neg_s.get_picoseconds(), content="0")
  let s2 = Span::of_ms(1500L)
  let neg_s2 = -s2
  inspect(neg_s2.get_seconds(), content="-1")
  inspect(neg_s2.get_picoseconds(), content="-500000000000")
}
