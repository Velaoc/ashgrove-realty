<!-- foundation:identity -->
# Ashgrove Realty

A CRM for a real estate office: track contacts buyers and sellers, property listings, and deals through a sales pipeline, with notes on every contact.

- Site: https://ashgrove-realty.api.holode.xyz
- Support: support@ashgrove-realty.api.holode.xyz
<!-- /foundation:identity -->

## What this is

A CRM for a real estate office: track contacts (buyers and sellers), property listings, and deals through a sales pipeline, with notes on every contact.

## Who it is for

- agent (office staff)
- admin (office manager)

## Main features

- **Manage contacts** — Create, edit, and view buyers and sellers with their details
- **Log notes on contacts** — Add timestamped notes to any contact and see them in chronological order
- **Add properties** — Record property listings with address, price, beds/baths, status
- **Run the deal pipeline** — Create deals, attach a contact (and optionally a property), and move them through stages: New, Contacted, Showing, Offer, Under Contract, Closed
- **View the pipeline** — See all deals grouped by stage and drill into any deal

## Core entities

- Contact
- Note
- Property
- Deal

## Included foundation modules

- crm

## Run locally

```bash
bundle install
bin/rails db:prepare
bin/dev
```

Requires Ruby, PostgreSQL, and the usual Rails toolchain. See `bin/setup` if present.

## Demo

A handful of contacts (mix of buyers and sellers), a few property listings at different statuses, several deals spread across pipeline stages with different values, and sample notes on contacts so every screen reads real.

## Deploy notes

Production `config.hosts` is derived from `domain` in `config/foundation.yml`. Keep that value aligned with the real host or every request will 403.
