## Notes
- Heart rate + battery come from standard BLE services (0x180D / 0x180F). SpO₂, BP, temperature and steps are simulated until you map your device's custom characteristics in `lib/providers/health_provider.dart`.
- Tap **Demo band** on the Device screen to try everything without hardware.
- `lib/services/ai_service.dart` is rule-based; swap `answer()` for an LLM call via your own backend.
- Not a medical device.
