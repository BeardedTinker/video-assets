# Lymow with Home Assistant

**Video:** https://youtu.be/yfEu37pZc4Y

This example combines the community Lymow integration with a practical mower
dashboard, a live GeoJSON map, and a notification containing statistics from the
last completed mowing session.

## Prerequisites

- Home Assistant 2024.1 or newer
- [HACS](https://hacs.xyz/)
- [Lymow Home Assistant integration](https://github.com/d3dfantasy99/Lymow-HA)
- A Lymow mower already paired with the official app

The integration is unofficial and installed as a custom HACS repository. Check
its current documentation for supported login methods, regions, and entities.

The map in [`dashboard.yaml`](./dashboard.yaml) additionally uses
[Map Card](https://github.com/nathan-gs/ha-map-card).

## Included files

- [`dashboard.yaml`](./dashboard.yaml) — controls, live session data, mower
  status, and a coordinate-free GeoJSON map.
- [`template-sensors.yaml`](./template-sensors.yaml) — separates the integration's
  combined GeoJSON into zones, mowed area, dock, and robot layers.
- [`automation-mowing-complete.yaml`](./automation-mowing-complete.yaml) — sends
  area, duration, and battery-use statistics when a session completes.

## Setup

1. Install and configure the Lymow integration.
2. Confirm the entity IDs created for your mower.
3. Add the template sensors to your Home Assistant configuration and reload
   Template Entities.
4. Add the dashboard card and replace the example `lymow_one_plus` IDs.
5. Replace `notify.mobile_app_your_phone` in the automation with your notify
   entity, then add and reload the automation.

Some diagnostic sensors are disabled by default. Enable any entity used by the
dashboard if it is not already available.

## Session duration

The completion event reports `duration_s` in **seconds**. The included
automation divides it by 60 before displaying minutes. Do not label the raw
value as minutes.

## Privacy and safety

GeoJSON can reveal the exact location and shape of a property. The examples do
not contain fixed coordinates; review screenshots and exported states before
sharing them. Always check that the lawn is clear before remotely starting the
mower.

## Disclaimer

Lymow is a trademark of its respective owner. The linked Home Assistant
integration is an unofficial community project and may change when the vendor's
service changes.
