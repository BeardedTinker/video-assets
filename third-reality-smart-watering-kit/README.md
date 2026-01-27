# Third Reality Smart Watering Kit (Home Assistant)
**Video:** https://youtu.be/PLACEHOLDER_VIDEO_LINK  
**Devices:**
- Smart Watering Kit: https://thirdreality.com/product/smart-watering-kit/
- Smart Soil Moisture Sensor: https://thirdreality.com/product/smart-soil-moisture-sensor/

This folder contains Home Assistant YAML (HA 2026.1+) used to build a reliable, “set-and-forget” watering setup with:
- interval-based watering (simple schedule)
- optional soil-moisture “smart” top-up (only when truly dry)
- pump failsafe (force off if stuck on)
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
- The “smart” watering trigger waits **10 minutes** under LOW before acting (anti-flap).
- The pump run script has a hard cap of **120s** for safety.
