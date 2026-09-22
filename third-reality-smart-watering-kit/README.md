# Third Reality Smart Watering Kit (Home Assistant)
**Video:** https://youtu.be/PLACEHOLDER_VIDEO_LINK

**Devices:**
- Smart Watering Kit: https://thirdreality.com/product/smart-watering-kit/
- Smart Soil Moisture Sensor: https://thirdreality.com/product/smart-soil-moisture-sensor/

This folder contains Home Assistant YAML (HA 2026.1+) used to build a reliable, “set-and-forget” watering setup with:
- interval-based watering (simple schedule)
- optional soil-moisture “smart” top-up (only when truly dry)
- pump safety checks, startup shutoff retry, and a 130-second runtime failsafe
- battery alerts (soil sensor + pump)
- health check for sensor availability

✅ No low-water sensor is used (the kit doesn’t provide one).

## Files
- 📦 [Package YAML](./home-assistant/packages/third_reality_watering.yaml)

## Entities used (example)
Replace these with your entity IDs:
- `sensor.basil_humidity` (soil moisture %)
- `sensor.basil_temperature` (°C) *(optional / informational)*
- `sensor.basic_battery` (% soil sensor battery)
- `switch.water_pump`
- `input_number.water_pump_duration` (seconds)
- `input_number.water_pump_interval` (days)
- `input_datetime.water_pump_last_run` (shared, persistent last accepted run)
- `sensor.water_pump_battery` (% pump battery)
- `notify.telegram_ebrzsmbrbot` (notifications)

## Install (Package)
1. Copy `home-assistant/packages/third_reality_watering.yaml` into your HA `/config/packages/` folder.
2. Ensure packages are enabled in `configuration.yaml`:
   ```yaml
   homeassistant:
     packages: !include_dir_named packages
   ```
3. Restart Home Assistant

## Notes / tuning
- Adjust moisture thresholds:
  - `input_number.basil_moisture_low` (default 18%)
  - `input_number.basil_moisture_target` (default 28%)
- Set `input_number.water_pump_duration` from **1–120 seconds** (default 20 seconds).
- Set `input_number.water_pump_interval` from **1–30 days** (default 1 day).
- Scheduled and soil-triggered watering share `input_datetime.water_pump_last_run`, so either accepted run starts the same persistent cooldown for both paths.
- The “smart” watering trigger waits **10 minutes** under LOW before acting (anti-flap).
- The pump script rejects durations below 1 second, caps longer requests at **120 seconds**, and records the run only after the pump reports that it is on.
- Home Assistant startup requests an immediate shutoff and waits to retry when the pump entity becomes available. A separate failsafe forces it off after **130 seconds** continuously on, leaving margin above the valid 120-second maximum.
