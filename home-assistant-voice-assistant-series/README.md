# Home Assistant Voice Assistant Series

This series tests Home Assistant-compatible voice hardware in a real home and
then explores the shared software behind it: Assist pipelines, Music Assistant,
languages, and custom intents.

The goal is to show responsiveness, usability, reliability, and limitations.
These are practical comparisons, not laboratory hardware benchmarks.

## Published videos

- [I'm Testing 3 Very Different Home Assistant Voice Assistants](https://youtu.be/kKDNd6tnFzE)
- [This Google Home Mini Runs Home Assistant Now](https://youtu.be/pB5rBzix3V0) — MiciMike Home Mini

Links for additional hardware videos will be added after publication.

## Public device references

- [MiciMike Home Mini](https://www.crowdsupply.com/micimike-rev-devices/micimike-home-mini-drop-in-pcb)
  and its [GitHub project](https://github.com/iMike78/home-mini-v1-drop-in-pcb)
- [Third Reality Voice & Music Assistant Dev Edition](https://www.thirdreality.com/products/voice-music-assistant-dev-edition)
  and its [firmware](https://github.com/thirdreality/voice-music-assistant)
- [Seeed Studio reSpeaker XVF3800](https://wiki.seeedstudio.com/respeaker_xvf3800_xiao_home_assistant/)
- [Home Assistant Voice Preview Edition](https://www.home-assistant.io/voice-pe/)
- [FutureProofHomes Satellite1](https://futureproofhomes.net/)

## Reusable files

- [`benchmark-methodology.md`](./benchmark-methodology.md) defines the common
  test categories, timer start/stop points, and fair-comparison rules.
- [`test-environment-template.md`](./test-environment-template.md) is a blank
  record for Home Assistant, firmware, pipeline, room, command, and result data.

No result table is published until measurements have actually been recorded.
Failed commands remain failures rather than receiving estimated response times.

## Series scope

Individual hardware videos focus on setup, wake-word behaviour, practical voice
commands, response latency, microphone performance, feedback, and reliability.
They do not attempt to exhaustively compare every STT/TTS engine, conversation
agent, language, acoustic property, or multi-room audio configuration.

Planned follow-up topics include:

- voice control and playback through Music Assistant;
- Assist pipeline configuration and troubleshooting;
- custom sentences, custom intents, and multilingual Assist testing.

## Reusing the methodology

Keep the command wording and Assist pipeline equivalent where possible. Record
every material difference, use the timing definition exactly, and publish raw
failures alongside successful attempts. Complete a fresh copy of the test
environment template for each device or comparison run.
