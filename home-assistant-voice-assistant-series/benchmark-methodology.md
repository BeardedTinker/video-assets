# Real-World Voice Assistant Comparison Methodology

This method is designed for repeatable Home Assistant demonstrations in a real
home. It supports useful comparisons without claiming laboratory precision.

## Test categories

1. **Setup and integration** — installation, discovery, firmware, available
   controls, and initial configuration.
2. **Wake-word recognition** — reliable activations and unintended activations.
3. **Voice commands** — lights, switches, and other supported Home Assistant
   actions.
4. **Information requests** — time, weather, and questions supported by the
   configured pipeline.
5. **Response latency** — end of the spoken command to the first observable
   result.
6. **Microphone performance** — recognition at documented distances and noise
   conditions.
7. **Usability** — controls, LEDs, sounds, speaker clarity, and device-specific
   capabilities.
8. **Reliability** — failures, retries, unexpected behaviour, and limitations.

Only report a category when it was actually tested. Keep optional future tests
separate from completed observations.

## Response timer

Use the same timing rule for every device and editing timeline.

- **START:** the end of the spoken user command.
- **STOP:** the first reliably observable result of the requested action.
- For a light command, the execution chirp may be used only when it reliably
  coincides with the actual light action.
- For a spoken answer such as the time, stop at the beginning of the answer.
- If there is no chirp, use the first visible action or audible response.
- Ignore a later completion announcement when the requested action already
  happened.
- Label a failed command as a failure. Do not assign an estimated successful
  response time.

The reusable DaVinci Resolve/Fusion overlay is named **BT Voice Response Timer**.
At 30 fps, frame-level placement has a resolution of approximately 33 ms.

This measures **time to first observable result**. It does not isolate wake-word,
STT, intent, conversation-agent, network, action-execution, or TTS latency.

## Fair-comparison rules

- Use equivalent commands and the same Assist pipeline when possible.
- Record Home Assistant, device firmware, pipeline, network, room, device
  position, distance, and background-noise differences.
- Keep action-response and speech-response results in separate categories.
- Use multiple attempts and publish the attempt count; do not select only the
  fastest successful result.
- Keep failed commands and retries in the record.
- Do not claim identical conditions when they cannot be established.
- Do not compare rounded on-screen values as if they were more precise than the
  source timeline.

## Suggested test sequence

1. Record the environment and software versions.
2. Confirm the device is idle and ready for the same wake word and pipeline.
3. Run the chosen command list in a fixed order.
4. Mark START and STOP in the 30 fps timeline for each successful attempt.
5. Record failures without inventing a latency value.
6. Repeat under each explicitly documented distance or noise condition.
7. Publish the raw attempt table before writing conclusions.

## Out of scope for a single hardware review

- exhaustive speaker-frequency or microphone-sensitivity measurements;
- every available STT, TTS, and conversation-agent combination;
- comprehensive multilingual accuracy;
- complete Music Assistant and multi-room synchronization testing;
- local-versus-cloud pipeline optimization;
- exhaustive custom sentence and custom intent coverage.

These topics need separate conditions and should be identified as separate
tests rather than folded into a device score.
