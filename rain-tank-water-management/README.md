# Rain Tank Water Management

This project shows the architecture and logic behind my Home Assistant rainwater tank automation system.

What started as a simple pump control setup slowly evolved into a full state-driven water-management system with:
- low-water protection
- freeze-risk lockouts
- weather-aware irrigation logic
- presence-aware pump control
- future smart garden expansion

The goal was never “remote control”.

The goal was system awareness and resource protection.

---

## Video

YouTube video:
https://youtu.be/d59JP1xSzaM

---

## Features

- Rain tank level monitoring
- Pump protection logic
- Low-water lockout states
- Freeze-risk detection
- Presence-aware automation
- Rain detection logic
- Weather forecast integration
- Irrigation permission logic
- State-driven automations
- Recovery logic after refill/recovery

---

## System Architecture

```text
Rain Sensor ─┐
Weather ─────┤
Presence ────┤
Tank Level ──┤
Temp Sensor ─┤
             ▼
      Home Assistant Logic
             ▼
     Pump Permissions
             ▼
      Shelly → Pump
```

The system combines multiple imperfect signals together instead of relying on one “perfect” sensor.

---

## Hardware Used

- Zigbee water level sensor:
  https://s.click.aliexpress.com/e/_c3mJKPzF (*)

- Zigbee rain sensor:
  https://s.click.aliexpress.com/e/_c3Jc7uiZ (*)

- Shelly relay for pump control

- Gardena water pump

- Third Reality soil moisture sensors

- Sonoff Zigbee water valves (planned irrigation expansion)

(*) indicates affiliated links.

---

## Required Helpers

This project relies heavily on Home Assistant helpers and state-driven logic.

Main helpers used:

- `input_boolean.rain_water_system_enabled`
- `input_boolean.rain_tank_auto_mode`
- `input_boolean.rain_tank_maintenance_mode`
- `input_boolean.rain_tank_freeze_lockout`
- `input_boolean.rain_tank_low_water_lockout`
- `input_boolean.irrigation_enabled`

---

## Template Binary Sensors

Included:
- Rain Tank Pump Allowed
- Irrigation Allowed
- Rain Tank Has Water
- Rain Tank Freeze Risk
- Vegetable Zone Dry
- Mediterranean Zone Dry

See:
`template_binary_sensors.yaml`

---

## Included Automations

### low_water_guardrail.yaml
Protects the pump from running dry and enables low-water lockouts.

### frost_risk_forecast.yaml
Uses forecast + live temperature data to predict freeze risk.

### freeze_lockout.yaml
Disables the system during dangerous freeze conditions.

### pump_state_controller.yaml
Centralized pump execution logic based on permission states.

### rain_detected_timestamp.yaml
Stores the timestamp of recent rain detection events.

---

## Dashboard Example

Example dashboard included in the repository.

Dashboard focuses on:
- system state visibility
- protection states
- permissions
- tank status
- irrigation logic

Example screenshot:

`images/dashboard-overview.png`

---

## Future Expansion

Planned additions:
- drip irrigation
- multi-zone watering
- resource prioritization
- weather-aware irrigation scheduling
- smarter garden automation

---

## Notes

This repository is not intended as a plug-and-play package.

Instead, it documents the architecture, logic, and automation design behind the system shown in the video.

You will likely need to adapt:
- entity IDs
- helper names
- thresholds
- hardware integrations
- notification services

to fit your own Home Assistant setup.
