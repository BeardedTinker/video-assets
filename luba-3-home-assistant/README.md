# Luba 3 with Home Assistant

**Video:** https://youtu.be/4_T3uiJQTY8

This example shows how I monitor and control a Mammotion Luba 3 from Home
Assistant. It includes a reusable dashboard card stack for mower controls,
current-session details, connectivity, positioning, and the mower map.

## Prerequisites

- Home Assistant 2026.1 or newer
- [HACS](https://hacs.xyz/)
- [Mammotion Home Assistant integration](https://github.com/mikey0000/Mammotion-HA)
- A Luba mower already configured in the Mammotion app

The integration is a custom HACS repository. Follow its current installation
and account-sharing guidance rather than copying credentials into YAML.

The map in [`dashboard.yaml`](./dashboard.yaml) additionally uses:

- [Map Card](https://github.com/nathan-gs/ha-map-card)
- [Mammotion Assets](https://github.com/mikey0000/ha-mammotion-assets)

## Included dashboard

[`dashboard.yaml`](./dashboard.yaml) is a single card stack that can be pasted
into a manual dashboard card. It provides:

- native start, pause, and dock controls;
- battery, progress, working area, and estimated time remaining;
- connection, satellite, and positioning information;
- a satellite map with the mower position and Mammotion GeoJSON overlay.

Entity IDs are installation-specific. Replace the example `luba_3` entity IDs
with those created for your mower. The file intentionally contains no fixed map
coordinates; the map follows the mower entity.

## Safety

Remote start is convenient, but Home Assistant cannot prove that the lawn is
clear. Check people, animals, toys, and weather conditions before starting the
mower, and keep the manufacturer's safety systems enabled.

## Disclaimer

Mammotion and Luba are trademarks of their respective owner. The linked Home
Assistant integration and dashboard plugins are community projects.
