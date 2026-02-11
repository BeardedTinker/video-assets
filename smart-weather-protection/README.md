# Smart Weather Protection (Home Assistant 2026.1+)

> Video: **Weather That Actually Means Something in Home Assistant**  
> YouTube: **[Stop Freeze Damage With This Home Assistant Setup](https://youtu.be/5NSTEpEOS90)**

This repo folder contains **protection-grade** automations that use weather data only when it actually matters:
- preventing freezing damage (rainwater tank + outdoor plumbing)
- preventing pump operation in dangerous conditions
- keeping indoor pipes safe with a minimum temperature safeguard

These automations are designed for **advanced HA users** and production use.

---

## Overview

### What’s included

1) **Freeze Protection Forecast (Rain Tank)**
- Pulls both **daily** and **hourly** forecasts.
- Finds upcoming frost / hard-freeze windows.
- Uses a real outdoor sensor for **“freeze right now” validation**.

2) **Rain Tank Low Water Cutoff**
- Prevents dry-running and sends warnings at low/high levels.
- If the pump is ON and the water is too low → force OFF + notify.

3) **Pump Freeze Block (Hard Safety)**
- If outdoor temp is < **1°C** → pump is not allowed to run (even if tank has water).
- If pump is turned on anyway → it is turned off immediately + critical notification.

4) **Kitchen Pipe Protection**
- If kitchen temperature drops below **1°C** → turns on heater for up to **60 minutes**.
- Heater can stop earlier if temperature rises above **4°C**.
- Critical notifications on start/stop and if temperature does not recover.

---

## Required entities (as used in my setup)

### Outdoor / Weather
- `weather.home` (any HA weather entity that supports `weather.get_forecasts`)
- `sensor.master_balcony_air_quality_temperature` (outdoor reference temp)

### Rain tank + pump
- `sensor.rain_tank_level_liquid_depth` (cm)
- `switch.water_pump`

### Indoor pipe protection (kitchen)
- `sensor.kitchen_climate_temperature`
- `switch.kitchen_heater`

### Notifications
- `notify.mobile_app_pixel_9_pro_xl`
- `notify.telegram_ebrzsmbrbot`

---

## Required integrations

- A HA Weather integration providing `weather.home`
- Any outdoor temperature sensor integration (ZHA in my case)
- Your pump/heater controls (Shelly / Zigbee / etc.)

---

## Comfort vs Protection

These automations are **Protection**, not Comfort.

- **Comfort** automations optimize convenience and energy.
- **Protection** automations aim to prevent damage, even if it costs energy or overrides normal “modes”.

That’s why:
- Pipe protection runs even if you’re **Away**
- Pump is blocked during frost risk even if tank level is safe

---

## Safety disclaimer

These automations reduce risk but **cannot guarantee safety**.
- Use proper insulation, drain valves, and frost-proof plumbing practices.
- Avoid relying solely on a single battery sensor for critical protection.
- Always verify behavior under real conditions (cold nights, restarts, sensor failures).

---

## How to adapt to your setup

1) Replace entity IDs in YAML files with your own.
2) Adjust thresholds:
   - Pipe ON threshold: **1°C**
   - Pipe OFF threshold: **4°C**
   - Max runtime: **60 minutes**
   - Pump freeze block: **< 1°C**
3) Decide how aggressive you want notifications and cooldowns.

---

## Optional improvement (recommended)

Add a second indoor sensor near pipes (e.g. pantry next to kitchen) and use it as a fallback:
- if kitchen sensor becomes `unavailable`, you can fail over to the secondary sensor
- this avoids “blind mode” if a battery dies

I didn’t include this in code because I don’t want to invent entity IDs that you don’t use.

---

## Install

You can use these YAML files in one of these ways:
- **packages** (recommended)
- split includes:
  - `automation: !include_dir_merge_list automations/`
  - `input_boolean: !include helpers/example_helpers.yaml` etc.

After adding files:
1) Validate config
2) Restart Home Assistant
3) Test using Developer Tools (turn pump ON, simulate low temp, etc.)

---
