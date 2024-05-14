import 'package:internet_speed_test/src/callbacks_enum.dart';

///
class TestResult {
  ///
  TestResult(
    this.type,
    this.transferRate,
    this.unit, {
    // Duration to complete
    int durationInMillis = 0,
  }) : durationInMillis = durationInMillis - (durationInMillis % 1000);

  ///
  final TestType type;

  ///
  final double transferRate;

  ///
  final SpeedUnit unit;

  ///
  final int durationInMillis;
}
