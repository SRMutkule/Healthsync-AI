import '../models/insight.dart';
import '../providers/health_provider.dart';
import '../providers/profile_provider.dart';
import '../utils/status.dart';

/// Local rule-based "AI" engine. Replace [answer] with a call to a real LLM
/// (through your own backend, so no API key ships in the app) when ready.
class AiService {
  static List<Insight> analyze(HealthProvider h, ProfileProvider p) {
    final out = <Insight>[];

    final hr = hrStatus(h.heartRate);
    out.add(Insight(
      'Heart rate: ${h.heartRate.round()} bpm',
      hr.level == Level.good
          ? 'Within the typical resting range (60–100 bpm).'
          : 'Outside the typical resting range (60–100 bpm). If you were not active, rest and re-check.',
      hr.level,
    ));

    final o2 = spo2Status(h.spo2);
    out.add(Insight(
      'Oxygen saturation: ${h.spo2.round()}%',
      o2.level == Level.good
          ? 'Healthy oxygen level.'
          : 'Below 95%. Check sensor fit and breathe calmly; seek care if it stays below 92% or you feel breathless.',
      o2.level,
    ));

    final bp = bpStatus(h.systolic, h.diastolic);
    out.add(Insight(
      'Blood pressure: ${h.systolic.round()}/${h.diastolic.round()} mmHg',
      bp.level == Level.good
          ? 'Blood pressure looks healthy.'
          : 'Outside the ideal range. Re-measure seated after 5 minutes of rest and track it over several days.',
      bp.level,
    ));

    final t = tempStatus(h.temperature);
    out.add(Insight(
      'Temperature: ${h.temperature.toStringAsFixed(1)} °C',
      t.level == Level.good
          ? 'Normal body temperature.'
          : 'Off the normal band (36.0–37.4 °C). Stay hydrated and monitor for other symptoms.',
      t.level,
    ));

    final ratio = h.steps / p.stepGoal;
    out.add(Insight(
      'Steps: ${h.steps} / ${p.stepGoal}',
      ratio >= 1
          ? 'Daily goal reached. Great job!'
          : ratio >= 0.5
              ? 'You are over halfway to your daily goal.'
              : 'Low activity so far. A 15-minute walk would help.',
      ratio >= 0.5 ? Level.good : Level.warn,
    ));

    if ((p.data['conditions'] ?? '').isNotEmpty) {
      out.add(const Insight(
        'Medical history on file',
        'Share these trends with your doctor to personalise your targets.',
        Level.good,
      ));
    }
    return out;
  }

  static List<String> recommendations(HealthProvider h, ProfileProvider p) {
    final r = <String>[];
    if (hrStatus(h.heartRate).level != Level.good) {
      r.add('Sit down and breathe slowly for 2 minutes (4s in, 6s out), then re-check your heart rate.');
    }
    if (spo2Status(h.spo2).level != Level.good) {
      r.add('Make sure the sensor fits snugly, your hands are warm, and the room is ventilated.');
    }
    if (bpStatus(h.systolic, h.diastolic).level != Level.good) {
      r.add('Reduce salt and caffeine today, and log your blood pressure at the same time each day.');
    }
    if (tempStatus(h.temperature).level != Level.good) {
      r.add('Drink fluids, rest, and see a doctor if fever persists beyond 48 hours.');
    }
    if (h.steps < p.stepGoal) {
      r.add('Take short walking breaks: ${p.stepGoal - h.steps} steps remain for today.');
    }
    r.addAll([
      'Drink about 2–3 litres of water through the day.',
      'Aim for 7–9 hours of sleep with a consistent schedule.',
      'Include 150 minutes of moderate exercise per week.',
      'Eat plenty of vegetables, fruit, whole grains and lean protein.',
    ]);
    return r;
  }

  static String answer(String q, HealthProvider h, ProfileProvider p) {
    final s = q.toLowerCase();
    bool has(List<String> w) => w.any(s.contains);

    if (has(['chest pain', 'faint', 'unconscious', 'stroke', "can't breathe", 'cannot breathe', 'emergency'])) {
      return '⚠️ This may be an emergency. Call your local emergency number now (112 in India) or go to the nearest hospital. Do not wait for app readings.';
    }
    if (has(['heart', 'pulse', 'bpm'])) {
      return 'Your heart rate is ${h.heartRate.round()} bpm (${hrStatus(h.heartRate).label.toLowerCase()}). A normal resting rate is 60–100 bpm. Caffeine, stress, dehydration and poor sleep can raise it.';
    }
    if (has(['spo2', 'oxygen', 'saturation'])) {
      return 'Your SpO₂ is ${h.spo2.round()}%. 95–100% is normal. Persistent readings under 92%, or breathlessness, need medical attention.';
    }
    if (has(['blood pressure', 'bp', 'hypertension'])) {
      return 'Your blood pressure is ${h.systolic.round()}/${h.diastolic.round()} mmHg (${bpStatus(h.systolic, h.diastolic).label.toLowerCase()}). Ideal is around 120/80. Limit salt, stay active and manage stress.';
    }
    if (has(['temperature', 'fever'])) {
      return 'Your temperature is ${h.temperature.toStringAsFixed(1)} °C. Fever starts around 38 °C. Rest, drink fluids, and consult a doctor if it lasts more than two days.';
    }
    if (has(['step', 'walk', 'activity', 'exercise', 'workout'])) {
      return 'You have taken ${h.steps} steps (goal ${p.stepGoal}), covering ${h.distanceKm.toStringAsFixed(2)} km and burning about ${h.calories.round()} kcal. Adults benefit from 150 minutes of moderate activity weekly.';
    }
    if (has(['sleep', 'insomnia'])) {
      return 'Most adults need 7–9 hours. Keep a fixed schedule, avoid screens and caffeine late in the day, and keep your room dark and cool.';
    }
    if (has(['water', 'hydrat'])) {
      return 'Aim for roughly 2–3 litres of fluids daily, more in hot weather or when exercising. Pale-yellow urine is a good sign.';
    }
    if (has(['diet', 'food', 'eat', 'weight'])) {
      return 'Build meals around vegetables, fruit, whole grains, legumes and lean protein; limit sugary drinks and ultra-processed foods. For a personal plan, see a registered dietitian.';
    }
    if (has(['stress', 'anxiety', 'mental'])) {
      return 'Try slow breathing, a short walk, or journaling. If stress or low mood persists for weeks, please talk to a mental health professional.';
    }
    if (has(['score'])) {
      return 'Your Health Score combines your vitals status with progress toward your step goal. It is currently ${h.healthScore(p.stepGoal)}/100.';
    }
    return 'I can help with heart rate, SpO₂, blood pressure, temperature, activity, sleep, hydration and diet. Try asking, "Is my heart rate normal?"';
  }
}
