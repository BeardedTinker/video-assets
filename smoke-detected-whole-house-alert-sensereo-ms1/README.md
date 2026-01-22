# Smoke Detected → Whole House Alert (Matter + Home Assistant)
**Device:** Sensereo MS1 (Matter smoke detector, Thread)  
**Video:** https://www.youtube.com/watch?v=X_DA_vfuB2Y  
**Product link (*):** https://shop.sensereo.com/products/smoke-alarm-ms-1?sca_ref=10461401.OZ1rik9K8fJb

This folder contains Home Assistant YAML examples used in the video to turn a smoke detector into a **whole-house alert system**:
push notifications, Telegram, optional TTS, scenes, HVAC shutdown, health checks and reminders.

## Important safety note
The smoke detector has its **own local siren** and should still alarm even if your smart home or Wi-Fi is down.  
Home Assistant automations here are an **extra layer** for whole-house notifications and actions.  
Always follow local safety regulations and use certified devices.

## Files

- 📁 [All automations](./home-assistant/automations/)
- 🔥 [FIRE – Smoke Detected (Upper Landing)](./home-assistant/automations/fire_smoke_detected_upper_landing.yaml)
- 🔋 [Low Battery (Upper Landing)](./home-assistant/automations/smoke_low_battery_upper_landing.yaml)
- ⚠️ [Fault (Upper Landing)](./home-assistant/automations/smoke_fault_upper_landing.yaml)
- 🧹 [Contamination Warning](./home-assistant/automations/smoke_contamination_warning_upper_landing.yaml)
- 🧪 [Monthly Self-Test Reminder](./home-assistant/automations/smoke_monthly_self_test_reminder_upper_landing.yaml)

## Entities used (example)
Replace these with your own entity IDs:
- `binary_sensor.upper_landing_smoke_smoke`
- `binary_sensor.upper_landing_smoke_battery_alert`
- `binary_sensor.upper_landing_smoke_hardware_fault`
- `binary_sensor.upper_landing_smoke_end_of_service`
- `sensor.upper_landing_smoke_contamination_state`
- `button.upper_landing_smoke_self_test` (optional)

Notifications (example):
- `notify.mobile_app_pixel_9_pro_xl`
- `notify.telegram_ebrzsmbrbot`

Optional:
- `script.say_living_room` (TTS)
- `switch.*` (HVAC)
- `scene.*` / `light.*` (lights)

---

# How to install

## Option A — Separate automation files (recommended)

Add this to your `configuration.yaml`:

```yaml
automation: !include_dir_merge_list automations
```
Then copy all YAML files from:

`home-assistant/automations/`

Copy these files into your Home Assistant `/config/automations/` folder.

Restart Home Assistant.

---

## Affiliate disclosure
Links marked with (*) are affiliate links.
