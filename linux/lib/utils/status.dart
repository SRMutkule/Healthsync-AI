import 'package:flutter/material.dart';

enum Level { good, warn, bad }

class Status {
  final String label;
  final Level level;
  const Status(this.label, this.level);
  Color get color => levelColor(level);
}

Color levelColor(Level l) {
  switch (l) {
    case Level.good:
      return const Color(0xFF2E9E5B);
    case Level.warn:
      return const Color(0xFFE59A12);
    case Level.bad:
      return const Color(0xFFD64545);
  }
}

Status hrStatus(double v) {
  if (v < 50 || v > 120) return const Status('Abnormal', Level.bad);
  if (v < 60 || v > 100) return const Status('Borderline', Level.warn);
  return const Status('Normal', Level.good);
}

Status spo2Status(double v) {
  if (v < 90) return const Status('Low', Level.bad);
  if (v < 95) return const Status('Borderline', Level.warn);
  return const Status('Normal', Level.good);
}

Status bpStatus(double sys, double dia) {
  if (sys >= 140 || dia >= 90 || sys < 90 || dia < 60) {
    return const Status('Abnormal', Level.bad);
  }
  if (sys >= 130 || dia >= 85) return const Status('Elevated', Level.warn);
  return const Status('Normal', Level.good);
}

Status tempStatus(double v) {
  if (v >= 38 || v < 35) return const Status('Abnormal', Level.bad);
  if (v >= 37.5 || v < 36) return const Status('Borderline', Level.warn);
  return const Status('Normal', Level.good);
}
