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
        ┌────┴─────┐
        ▼          ▼
  Pump Demand  Pump Permission
        │          │
        ▼          ▼
  Shelly → Pump ← Off-Only Safety Interlock
```

The system combines multiple imperfect signals together instead of relying on one “perfect” sensor.

`switch.water_pump` directly runs the pump. A manual action or a separate
demand automation must start and stop it; `binary_sensor.rain_tank_pump_allowed`
is permission, not demand, and never starts the pump. Demand logic should check
that permission is `on` before starting the pump. The pump-state controller is
an off-only safety interlock that stops the pump whenever permission is `off`,
`unknown`, or `unavailable`, including at Home Assistant startup.

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
- Vegetable Zone Dry (placeholder; always `false` until real logic is added)
- Mediterranean Zone Dry (placeholder; always `false` until real logic is added)

See:
`template_binary_sensors.yaml`

---

## Included Automations

### low_water_guardrail.yaml
Protects the pump from running dry and enables low-water lockouts.

### frost_risk_forecast.yaml
Uses forecast + live temperature data to predict freeze risk.

### pump_state_controller.yaml
Off-only safety interlock that stops unsafe pump operation. It never starts the pump.

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
