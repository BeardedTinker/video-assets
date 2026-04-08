# Smart Home SIEM (Wazuh + Home Assistant)

**Video:**  
👉 https://youtu.be/Kf4jMZCMwVI

In this video I show how I built a **real SIEM for my smart home** using **Wazuh** and integrated it with **Home Assistant dashboards and sensors**.

The goal is simple:

Turn raw security telemetry into **actionable smart home signals**.

---

## Architecture Overview

Smart home telemetry sources:

- Home Assistant (journald logs)
- UniFi firewall / IDS / IPS events
- Synology NAS authentication logs
- Linux system logs

All logs are collected and analyzed by:

**Wazuh SIEM**

Then exposed back into **Home Assistant** using REST sensors and template sensors.

---

## Related Repositories

### Wazuh Rules / Decoders
👉 https://github.com/BeardedTinker/wazuh-homelab-security

Contains:

- custom decoders  
- detection rules  
- example logs  
- dashboards  

Focus: **UniFi + Synology + Home Assistant homelabs**

---

### Home Assistant Wazuh Agent Add-on
👉 https://github.com/BeardedTinker/ha-wazuh-agent-addon/

This add-on forwards **Home Assistant system logs (journald)** to Wazuh.

This allows Wazuh to detect:

- login attempts  
- authentication failures  
- suspicious activity  
- system events  

directly from Home Assistant.

---

## Home Assistant Integration

The Home Assistant side exposes several **REST sensors** that query Wazuh directly.

These sensors power:

- dashboards  
- security score  
- threat feeds  
- firewall monitoring  

Example metrics included in this repository:

- Critical alerts (24h)
- High alerts (24h)
- Medium alerts (24h)
- Low alerts (24h)
- Security Score
- Top rule triggered
- WAN firewall drop statistics
- Top WAN source IP
- Top WAN destination port

---

## Files in this folder

```
templates/
  wazuh_templates.yaml
```

Contains template sensors used for:

- security scoring
- UI-friendly alert display

```
sensors/
  wazuh_rest_sensors.yaml
```

Contains REST sensors querying the Wazuh indexer.

---

## Requirements

- Wazuh SIEM running (tested on **Wazuh 4.14.x**)
- Home Assistant **2026.1+**
- Wazuh indexer accessible via API
- credentials stored in `secrets.yaml`

Example:

```
wazuh_proxy_user: your_user
wazuh_proxy_pass: your_password
```

---

## Security Disclaimer

Never expose your Wazuh API directly to the internet.

Recommended setup:

- Wazuh accessible only on LAN
- or via VPN
- or via reverse proxy with authentication

---

## Adapting to Your Setup

You will likely need to change:

- Wazuh server IP
- index name
- authentication credentials
- entity IDs
- thresholds / polling intervals

Example from my setup:

```
resource: "https://192.168.1.39:8443/wazuh-alerts-*/_search"
```

---

## What surprised me

Once connected, the SIEM immediately revealed:

- constant WAN scanning
- automated port probing
- firewall activity patterns
- unusual authentication attempts

Exactly the kind of signals that normally stay **invisible in a smart home**.

---

## Why this matters

A modern smart home is effectively a **small data center**.

Treating it with proper **observability** and **security monitoring** is no longer optional if you care about reliability, detection, and long-term maintenance.

Wazuh makes that possible without enterprise budgets.

---

## Notes

- The YAML files here are meant as **real-world examples**, not one-click installs.
- Adjust thresholds and queries to match your environment.
- Store credentials in `secrets.yaml`, not directly in sensor files.
- If your Wazuh setup uses different index names, agent names, or decoder names, update the queries accordingly.
