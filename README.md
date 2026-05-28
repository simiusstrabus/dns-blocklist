# dns-blocklist
This is a block list (bulk.txt), created from over 600 smaller blocklists (blocklist-origins.txt) for pi-hole. It blocks over 18 million domains.

# Disclaimer

This blocklist is provided **as is** for advanced DNS filtering, privacy, security, and content-blocking purposes.

With approximately **18.1 million domains**, this is an extremely aggressive blocklist. False positives are expected, and legitimate services may be blocked either partially or completely. This can include websites, APIs, CDNs, streaming services, gaming platforms, software updates, authentication systems, telemetry endpoints, and other commonly used online services.

By using this blocklist, you acknowledge and accept that:

- Legitimate websites or applications may stop functioning correctly
- Some services may fail to connect, update, authenticate, or load content
- Network troubleshooting may become more difficult
- You are responsible for maintaining your own whitelist/allowlist
- No guarantee is provided regarding accuracy, completeness, or suitability for any purpose

This blocklist is intended for users who understand how DNS filtering works and who are comfortable diagnosing and resolving issues caused by blocked domains.

## Liability

The maintainer(s) of this blocklist are **not responsible** for:

- Broken websites or applications
- Service interruptions
- Data loss
- Network instability
- Financial losses
- Any direct or indirect damages resulting from use of this blocklist

**Use at your own risk.**

---

## Recommendation

Before deploying this blocklist widely, it is strongly recommended to:

- Test in a non-critical environment first
- Monitor DNS logs regularly
- Maintain a personal whitelist
- Use staged rollouts where possible
- Temporarily disable the list during troubleshooting

---

> ⚠️ This is an extremely aggressive blocklist. False positives will occur.
> Use only if you understand DNS filtering and are prepared to maintain your own whitelist.
