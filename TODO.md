# TODO list

Moreso for my own sanity so I stop forgetting to do things on this


## Lapis Retirement

Taking down Lapis in favour of using Amethyst form now on. Needs important things done by the end of the month.

- **[ ] - Important things to do before End of the month:**
  - [X] - Move TechDen Minecraft into the house (Move to Pearl?)
  - [X] - Copyparty (Probably move to Pearl rather than Amethyst)
    - [ ] - OOOO I can make use of the ISO syncthing share if I do this
    - [X] - Webfinger to Amethyst (Needed for Tailscale signins iirc, probably move as is and "reinvent the wheel" later)
  - [X] - VLMCSD KMS Emulator Container
  - **[ ] - Cancel Lapis**

- **[ ] - Less important items that I can take my time on**
  - [ ] - File Storage (Probably to an archive folder on Pearl)
  - [ ] - Move docker containers to Amethyst
    - [X] - cloudflared (Probably move to a nixos module and redefine things to talk to 127.0.0.1)
    - [X] - Documentations sites
      - [ ] - Containers
        - [X] - Docs DND Colosseum 2022
        - [X] - Docs DND Hiku 2025
        - [X] - Docs Main
      - [X] - Pipelines for each of the containers
    - [X] - Muse

## Retirement of Infra Playbook

Systems that need to be moved into Nix:

- [X] - Caddy
- [ ] - Docker Registry
- [ ] - Fail2Ban (Crowdsec?)
- [ ] - Firefox Sync Server ? (Probably get rid of this tbh)
- [ ] - Gickup
- [ ] - PwnDrop? (Probably get rid of this since Copyparty does what I need for this)
- [ ] - VaultWarden
- [X] - Watchtower