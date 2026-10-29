# LLM Vision AI Security Without Frigate

**Video:** https://youtu.be/8Xuzu-WceDY

**Tested with:** Home Assistant 2026.10.4 (October 2026)

This project records a short buffered camera clip after a camera-native person
detection, sends five selected frames from that clip to LLM Vision, and creates
an occupancy-aware mobile notification and Timeline event.

It is designed for homes that already have an NVR and camera-side object
detection, but want richer AI summaries without adding Frigate only for that
purpose. It is not a replacement for an NVR, Frigate, an alarm system, or human
review.

## What is included

- [`automation.yaml`](./automation.yaml) — one complete buffered recording,
  LLM Vision analysis, Timeline event, and mobile notification example.
- [`secondary-lens-recording.yaml`](./secondary-lens-recording.yaml) — optional
  buffered B-roll recording for a second lens without a duplicate AI request.

The examples use generic entity IDs and placeholders. Replace every value
called out in [Adapt the example](#adapt-the-example) before enabling them.

## Prerequisites

- Home Assistant with a working `camera` entity.
- A compatible video stream exposed to Home Assistant.
- A person-detection `binary_sensor` or another suitable event trigger.
- [LLM Vision](https://github.com/valentinfrlch/ha-llmvision), installed through
  HACS and configured with an AI provider.
- A writable media directory, such as `/media/llmvision`.
- A Home Assistant Companion App notification action if you want mobile alerts.
- An optional `input_boolean.guest_mode` helper for the occupancy-aware prompt.

This workflow is not Reolink-specific. Other cameras can use the same pattern
when their Home Assistant integration exposes both a compatible stream and an
event entity suitable for the automation trigger.

## How the pre-buffer works

Home Assistant's `camera.record` action can combine two time windows:

```yaml
duration: 10
lookback: 10
```

- `lookback` requests footage from before `camera.record` was called.
- `duration` requests footage after recording begins.
- The resulting file is approximately 20 seconds long, although both values are
  targets and the exact clip length can vary by camera and HLS segment timing.

The lookback is available **only while Home Assistant already has an active HLS
stream**. If the stream starts only after person detection, there is no earlier
buffer to recover and the clip may begin too late.

### Enable and keep the stream active

1. Confirm that the camera stream plays in Home Assistant.
2. Open the camera entity's settings and enable **Preload stream**.
3. Restart Home Assistant if prompted, then verify that the stream reconnects.
4. Run the manual recording test below before enabling the AI automation.

`stream` is normally loaded automatically when `default_config:` is enabled. If
you do not use `default_config:`, add this to `configuration.yaml` and restart
Home Assistant after validating the configuration:

```yaml
stream:
```

Preloading keeps a live stream open continuously. It uses camera bandwidth,
network capacity, and Home Assistant CPU/memory. Use it only for permanently
powered cameras. **Do not enable continuous preloading for battery-powered
cameras**, because it can prevent sleep and rapidly drain the battery.

### Stream choice and codecs

For this workflow, a lower-bitrate Fluent/substream is usually more practical
than the full-resolution main stream. Home Assistant Stream supports H.264 and
H.265 video, but H.264 generally has the broadest compatibility. AAC and MP3
audio are supported; common camera PCM codecs such as G.711 are not.

Choose a stream that:

- remains stable when left open continuously;
- gives the AI enough detail to identify actions and direction of travel;
- does not overload Home Assistant when several cameras are preloaded;
- produces an MP4 that LLM Vision can read consistently.

### Media directory and fixed filenames

Create `/media/llmvision` before testing. The example intentionally writes each
camera to a fixed filename:

```text
/media/llmvision/front_yard_event.mp4
```

This prevents short AI clips from accumulating forever. A later event replaces
the previous file, so use a unique filename per camera. Copy a clip elsewhere
before the next event if you want to preserve it. Your NVR remains the long-term
archive.

### Test recording before testing AI

From **Developer Tools → Actions**, run:

```yaml
action: camera.record
target:
  entity_id: camera.front_yard_fluent
data:
  filename: "/media/llmvision/prebuffer_test.mp4"
  duration: 10
  lookback: 10
```

Walk in front of the camera, call the action after movement has started, and
inspect the resulting file in Media. It should include footage from before the
action call. If it does not:

1. confirm **Preload stream** is enabled;
2. confirm the camera is using a stream supported by Home Assistant;
3. try the camera's H.264 substream;
4. check Home Assistant logs for Stream or FFmpeg errors;
5. adjust `lookback` and `duration` for that camera's segment timing.

Do not continue to AI analysis until this standalone recording works reliably.

## Configure LLM Vision

1. Install [LLM Vision](https://github.com/valentinfrlch/ha-llmvision) from the
   default HACS repository.
2. Restart Home Assistant.
3. Add the LLM Vision integration under **Settings → Devices & services**.
4. Add an OpenAI, other cloud, or supported local provider.
5. Replace `YOUR_LLM_VISION_PROVIDER_ID` in `automation.yaml` with the provider
   selected by the Home Assistant automation editor.

The example uses `gpt-4o-mini`, five frames, and a target width of 1280 pixels.
Five frames were a useful balance for this test, not a universal optimum. More
frames and larger images can increase latency and provider cost.

Review the current provider and model instructions in the
[LLM Vision documentation](https://llm-vision.gitbook.io/getting-started/setup/providers).
The integration also supports other cloud providers and local vision models.

## Adapt the example

In [`automation.yaml`](./automation.yaml), replace:

| Placeholder/example | Replace with |
| --- | --- |
| `binary_sensor.front_yard_person` | Your camera's person/event sensor |
| `camera.front_yard_fluent` | Your preloaded camera stream entity |
| `YOUR_LLM_VISION_PROVIDER_ID` | Your configured LLM Vision provider ID |
| `notify.mobile_app_your_phone` | Your Companion App notify action |
| `input_boolean.guest_mode` | Your guest helper, or simplify the occupancy template |
| `/lovelace/security` | Your preferred notification destination |

The sample renders one deterministic occupancy label before calling the model:

- `OCCUPIED`
- `OCCUPIED_OR_GUESTS_EXPECTED`
- `UNOCCUPIED_NO_GUESTS`

This reduces the chance that the model invents an occupancy state. It does not
make presence tracking infallible: GPS and network trackers can still report a
wrong state. Adapt the occupancy template to trustworthy signals in your home.

The classification prompt deliberately treats a person on private property as
at least `time-sensitive`. Calm behavior alone does not prove authorization.
`critical` remains reserved for forced entry, concealment, checking doors or
windows, or other clearly suspicious behavior. Rewrite the site context and
property-boundary rules for each camera view.

## Multi-lens cameras

Running AI independently on both lenses can create duplicate notifications and
double provider usage. Analyze the lens that gives the clearest event context,
and use [`secondary-lens-recording.yaml`](./secondary-lens-recording.yaml) only
when a second B-roll angle is useful.

Use a different filename for every lens. Both examples use `mode: single` and a
short cooldown to prevent overlapping writes to the same fixed file.

## Important limitations

- An LLM can miss people, hallucinate details, or assign the wrong importance.
- Camera-native detection decides when analysis starts; missed detections never
  reach the model.
- Provider latency and cost depend on model, frame count, image size, and event
  frequency.
- Cloud providers receive selected camera frames. Review their privacy and data
  retention terms before sending security footage.
- A fixed working file is overwritten by the next event.
- Preload stream increases continuous resource use.
- This workflow does not replace continuous NVR recording or certified security
  equipment.

## Related resources

- [LLM Vision repository](https://github.com/valentinfrlch/ha-llmvision)
- [LLM Vision documentation](https://llm-vision.gitbook.io/getting-started)
- [Home Assistant: Record camera feed](https://www.home-assistant.io/actions/camera.record/)
- [Home Assistant Stream integration](https://www.home-assistant.io/integrations/stream/)
- [Previous video: LLM Vision Integration](https://youtu.be/xQY60tYb5XQ)
- [Previous video: LLM Vision Timeline Card & Recap](https://youtu.be/-yzG4GGqT4I)
