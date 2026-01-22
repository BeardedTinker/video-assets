# I Deleted My HVAC Automations and Used This Instead (Climate Scheduler)
**Video:** https://youtu.be/co5V9xskrL0  
**Climate Scheduler repo:** https://github.com/kneave/climate-scheduler

This folder contains notes for the video.  
In the video I used **Climate Scheduler via UI only** (no custom YAML). The integration stores schedules internally (Home Assistant storage), so you won’t see a classic `automation.yaml` export unless you recreate it manually.

## What this video is about
Instead of building a growing mess of automations, helpers, templates and edge-case conditions, Climate Scheduler lets you manage HVAC schedules in a purpose-built UI — and keeps the logic maintainable.

## My example entities
Base climate entities used in the video:
- `climate.heatpump`
- `climate.ecobee`

## What Climate Scheduler may create in Home Assistant
Depending on how you set it up (single climate vs group/schedule), you may see entities like these:

### Rate sensors (temperature change rate)
Examples:
- `sensor.climate_scheduler_heatpump_rate`
- `sensor.climate_scheduler_ecobee_rate`

These are typically used by the integration to evaluate how temperature changes over time (°C/h).

### “Schedule climate” wrapper (group/schedule entity)
Example:
- `climate.climate_scheduler_climate_schedule_ecobee`

This represents a scheduler-controlled climate entity (often grouping one or more members).

### Schedule switch (enable/disable schedule)
Example:
- `switch.schedule_ecobee`

This is commonly used to toggle the schedule on/off. Attributes may include:
- `next_trigger`, `next_entries`
- `schedules` (weekday/weekend slots)
- `actions` that will be called on schedule changes

## Where to configure schedules
All scheduling is done from the **Climate Scheduler UI** (not YAML).  
You can inspect what it will do by looking at attributes on the created schedule entities (e.g. `switch.schedule_ecobee`).

## Common pitfalls (avoid the old mess)
- ❌ Don’t stack multiple automation layers on top (scheduler + lots of climate automations)  
  → you’ll lose track of what is controlling your HVAC
- ❌ Don’t over-optimize immediately  
  → start with a simple baseline schedule, then tune
- ✅ If you need “Away” or “Boost”, keep it minimal and obvious  
  → a single toggle or script is enough

## Quick troubleshooting checklist
- If nothing happens: check that the schedule switch is **On** (e.g. `switch.schedule_ecobee`)
- If actions look wrong: inspect `next_entries` / `schedules` attributes on the schedule entity
- If your climate ignores changes: confirm the underlying `climate.*` supports the service calls being issued

---

