# Smart Home SIEM (Wazuh + Home Assistant)

Video:  
👉 https://youtu.be/Kf4jMZCMwVI

In this video I show how I built a **real SIEM for my smart home** using **Wazuh** and integrated it with **Home Assistant dashboards and sensors**.

The goal is simple:

Turn raw security telemetry into **actionable smart home signals**.

---

# Architecture Overview

Smart Home telemetry sources:

• Home Assistant (journald logs)  
• UniFi firewall / IDS / IPS events  
• Synology NAS authentication logs  
• Linux system logs  

All logs are collected and analyzed by:

**Wazuh SIEM**

Then exposed back into **Home Assistant dashboards** using REST sensors.

---

# Related Repositories

## Wazuh Rules / Decoders

👉 https://github.com/BeardedTinker/wazuh-homelab-security

Contains:

• custom decoders  
• detection rules  
• example logs  
• dashboards

Focus: **UniFi + Synology + Home Assistant homelabs**

---

## Home Assistant Wazuh Agent Add-on

👉 https://github.com/BeardedTinker/ha-wazuh-agent-addon/

This add-on forwards **Home Assistant system logs (journald)** to Wazuh.

This allows Wazuh to detect:

• login attempts  
• authentication failures  
• suspicious activity  
• system events

directly from Home Assistant.

---

# Home Assistant Integration

The Home Assistant side exposes several **REST sensors** that query Wazuh directly.

These sensors power:

• dashboards  
• security score  
• threat feeds  
• firewall monitoring

Example metrics included in this repository:

• Critical alerts (24h)  
• High alerts (24h)  
• Medium alerts (24h)  
• Low alerts (24h)  
• Security Score  
• Top rule triggered  
• WAN firewall drop statistics

---

# Files in this folder
