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
