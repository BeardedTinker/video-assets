# Smart Home SIEM (Wazuh + Home Assistant)

**Video:** [Smart Home SIEM with Wazuh](https://youtu.be/Kf4jMZCMwVI)

This example connects Home Assistant to a Wazuh Indexer and turns security
telemetry into dashboard-ready entities. It uses four shared REST queries rather
than one HTTP request per sensor.

## What is included

- Exact 24-hour severity counts without the OpenSearch 10,000-hit cap
- Latest five high-severity security events
- Top elevated Wazuh rule
- WAN_LOCAL event count, top source IP, and top destination port
- Optional SafeLine totals, attack classes, correlations, top source, and last attack
- Last-successful-poll timestamp and defensive unavailable states
- A built-in-card Lovelace SIEM view

## Architecture

Typical telemetry sources include Home Assistant, UniFi, Synology, Linux hosts,
and SafeLine WAF. Wazuh decodes and indexes those events. Home Assistant reads
the Indexer through a LAN-only HTTPS reverse proxy using a restricted read-only
account.

Related projects:

- [Wazuh homelab rules and decoders](https://github.com/BeardedTinker/wazuh-homelab-security)
- [Home Assistant Wazuh Agent add-on](https://github.com/BeardedTinker/ha-wazuh-agent-addon)

## Files

```text
packages/
  wazuh.yaml                  # Four REST resources and the security-score sensor
dashboards/
  siem-view.yaml              # Portable Lovelace view using built-in cards
scripts/
  validate-embedded-json.sh   # YAML, query, and unique-ID validation
```

## Requirements

- Wazuh 4.14.x or a compatible OpenSearch-backed Indexer
- Home Assistant 2026.1 or newer
- A read-only Indexer or reverse-proxy account
- A trusted HTTPS certificate for the hostname used by Home Assistant
- The keyword subfields listed in [Mapping requirements](#mapping-requirements)

## Installation

### 1. Enable Home Assistant packages

If packages are not already enabled, add this under your existing
`homeassistant:` block in `configuration.yaml`:

```yaml
homeassistant:
  packages: !include_dir_named packages
```

Do not create a second `homeassistant:` key if one already exists.

### 2. Copy and configure the package

Copy `packages/wazuh.yaml` to your Home Assistant `packages/` directory, then
replace every `wazuh.example.internal` hostname with your Wazuh proxy hostname.
Keep the wildcard index path unless your Wazuh indices use another name.

Add credentials to `secrets.yaml`:

```yaml
wazuh_proxy_user: "your_read_only_user"
wazuh_proxy_pass: "your_password"
```

Never commit `secrets.yaml`.

### 3. Validate and restart

Run Home Assistant's **Check configuration**, then restart Core. A restart is
recommended when replacing old REST entities because a REST reload can leave
existing unique IDs active until the next startup.

After startup, verify that `sensor.wazuh_indexer_last_successful_poll` advances
every five minutes and that none of the Wazuh entities is unavailable.

### 4. Add the dashboard view

`dashboards/siem-view.yaml` is a single Lovelace view. Add it to the `views:`
list of a YAML dashboard, or paste the mapping as a new view through Home
Assistant's raw dashboard editor. It uses only built-in cards.

## Mapping requirements

Recent Wazuh indices commonly map the base fields below as `text`, with exact
values available through `.keyword`. Exact filters and terms aggregations must
therefore use the keyword subfields.

| Purpose | Required field |
|---|---|
| Top rule and correlation IDs | `rule.id.keyword` |
| SafeLine group | `rule.groups.keyword` |
| WAN decoder | `decoder.name.keyword` |
| Source-IP aggregation | `data.srcip.keyword` |
| Destination-port aggregation | `data.dstport.keyword` |
| SafeLine action | `data.action.keyword` |
| SafeLine attack type | `data.attack_type.keyword` |

Check the live mapping before installation:

```bash
curl --fail --silent --show-error \
  --user "$WAZUH_USER:$WAZUH_PASS" \
  "https://wazuh.example.internal:8443/wazuh-alerts-*/_field_caps?fields=decoder.name,decoder.name.keyword,data.srcip,data.srcip.keyword,data.dstport,data.dstport.keyword,rule.id,rule.id.keyword,rule.groups.keyword,data.action.keyword,data.attack_type.keyword" \
  | jq '.fields'
```

Do not paste credentials directly into the command or shell history.

### Why `decoder.name.keyword` matters

For an analyzed `text` field, this exact query can silently return zero hits:

```json
{"term": {"decoder.name": "unifi-wan-local"}}
```

Use the exact-value subfield instead:

```json
{"term": {"decoder.name.keyword": "unifi-wan-local"}}
```

The same rule applies to terms aggregations. Aggregating a `text` field can
produce a `fielddata` or `search_phase_execution_exception` error.

## Query design

The package intentionally uses only four shared requests:

1. Global severity KPIs, top elevated rule, and successful-poll timestamp
2. Latest five events with `rule.level >= 10`
3. WAN_LOCAL total and both WAN terms aggregations
4. SafeLine total, classifications, correlations, top source, and last attack

Every request uses `track_total_hits: true`. This prevents totals greater than
10,000 from being reported as exactly 10,000. Templates check for the expected
response object and become unavailable on malformed or error responses instead
of presenting a false zero.

## Adapting WAN_LOCAL

The example expects documents decoded as `unifi-wan-local`, with `data.srcip`
and `data.dstport` populated by the decoder. If your decoder uses another name,
change the value in the third REST query. If those structured fields are not
present, fix the Wazuh decoder rather than adding expensive per-query runtime
scripts over `full_log`.

WAN_LOCAL totals include every matching decoder event. The global top-rule
sensor includes only rules at level 7 or higher, so the two counts are not
expected to match.

## Optional SafeLine support

SafeLine sensors depend on events in the `safeline_waf_event` rule group and on
these normalized fields:

- `data.action`: `1` for blocked attacks
- `data.attack_type`: `0` for SQL injection and `1` for XSS
- `data.srcip`, `data.host`, and `data.path_only`
- final correlation rule IDs `100550` and `100551`

Without SafeLine events, these sensors remain valid and normally report zero or
`n/a`. The canonical example keeps the fourth query enabled so its validator can
enforce the documented four-query architecture. Advanced users can remove that
resource and dashboard section, but must also adjust the canonical count checks
in `scripts/validate-embedded-json.sh`.

## Migrating from the original split example

Before installing the package, remove the old individual REST sensors and the
old template file. In particular, do not keep these retired entities configured:

- `sensor.wazuh_ops_last_5`
- `sensor.wazuh_low_24h_display`

Keeping both versions causes duplicate unique IDs and can leave restored,
unavailable registry entries after restart. Remove or disable such stale entries
through Home Assistant's entity registry after confirming nothing references
them.

## HTTPS and access control

The example deliberately uses `verify_ssl: true`. Use a DNS hostname whose
certificate Subject Alternative Name matches that hostname. The certificate
chain must be trusted by the Home Assistant runtime.

Do not expose the Wazuh Indexer directly to the internet. Prefer a LAN-only or
VPN-only reverse proxy, a dedicated read-only account, and network restrictions
that allow only Home Assistant to reach the endpoint.

## Local validation

From the repository root:

```bash
bash smart-home-siem-wazuh/scripts/validate-embedded-json.sh
```

The validator checks YAML parsing, embedded JSON, all four
`track_total_hits` flags, TLS verification, and duplicate `unique_id` values.

## Troubleshooting

| Symptom | Likely cause |
|---|---|
| Total stops at `10000` | `track_total_hits` is missing or false |
| WAN total is `0` but WAN rules exist | Exact filter is using `decoder.name` instead of `.keyword` |
| `fielddata` error | A terms aggregation targets a `text` field |
| Sensors stay unavailable | TLS, credentials, endpoint, or Indexer response error |
| Duplicate-ID warnings after reload | Old REST definitions are still active; validate and restart |
| Poll timestamp is fresh but one section is unavailable | The global query works, but another shared query failed |

The YAML is an adaptable real-world example, not a one-click integration. Test
queries against your own live mapping before relying on the dashboard.
