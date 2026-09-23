# Smart Irrigation with Home Assistant

**Video:** https://youtu.be/jT2qFfi1r0c

This project shows the irrigation layer of my Home Assistant water-management
system: soil-moisture sensors provide context, Home Assistant decides whether
watering is needed and safe, and a Zigbee valve controls water delivery.

It is a follow-up to [Rain Tank Water Management](../rain-tank-water-management/),
which covers the rainwater source, pump protection, freeze lockouts, and shared
safety constraints.

## System Architecture

```mermaid
flowchart LR
    soil[Third Reality soil sensors] --> ha[Home Assistant irrigation logic]
    weather[Rain and weather context] --> ha
    tank[Rain tank and safety state] --> ha
    ha --> demand[Irrigation demand]
    demand --> valve[Sonoff Hydro valve]
    demand --> pump[Pressure pump]
    valve --> zones[Drip irrigation zones]
    pump --> zones
```

The important design distinction is between **demand** and **permission**:

- Soil moisture can request watering.
- Tank level, freeze protection, rain context, and system health decide whether watering is allowed.
- The valve and pump only run when demand and safety conditions agree.
- Shutdown logic turns demand off before stopping the pump and closing the valve.

## Devices

- [Third Reality Smart Soil Moisture Sensor Gen2](https://www.thirdreality.com/products/smart-soil-moisture-sensor-gen2?ref=BeardedTinker) (*)
- [SONOFF Hydro DUO dual-channel Zigbee smart water valve](https://sonoff.tech/en-eu/products/sonoff-hydro-duo-dual-channel-zigbee-smart-water-valve-swv-zf2e-swv-zf2u?ref=601&utm_source=affiliate) (*)
- [SONOFF Hydro ONE single-channel Zigbee smart water valve](https://sonoff.tech/en-eu/products/sonoff-hydro-series-hydro-one-zigbee-smart-water-valve-swv-zfu-swv-zfe?ref=601&utm_source=affiliate) (*) — single-channel alternative

Links marked with (*) are affiliate links. I may earn a small commission if you buy through them, at no extra cost to you.

## Related Project

For a smaller battery-powered watering setup for individual plants, see the
[Third Reality Smart Watering Kit](../third-reality-smart-watering-kit/).

## Notes

- This is an architecture overview, not a plug-and-play configuration.
- Adapt entity IDs, moisture thresholds, runtime limits, and safety conditions to your own installation.
- Smart-home automation is an additional control layer; use suitable plumbing, pressure regulation, and local hardware safeguards.
