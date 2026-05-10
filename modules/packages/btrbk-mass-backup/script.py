import sys
import os
import logging
import subprocess
import json
import argparse

enableDebug = False

# Logging setup

log = logging.getLogger()
log.setLevel(logging.DEBUG)
streamHandler = logging.StreamHandler(sys.stdout)
if enableDebug is True:
  streamHandler.setLevel(logging.DEBUG)
else:
  streamHandler.setLevel(logging.INFO)
formatter = logging.Formatter("%(asctime)s:%(levelname)s:%(message)s")
streamHandler.setFormatter(formatter)
log.addHandler(streamHandler)

log.debug("Setup logging sucessfully...")

parser = argparse.ArgumentParser(prog='btrbk-mass-backup-snapshot-prep', description='Takes JSON files and either preps or cleans up btrfs snapshots from a standard btrbk setup')
parser.add_argument('--action',
                    type=str,
                    choices=['prepare', 'cleanup'],
                    required=True,
                    help='Sets the action to either prepare or cleanup snapshots',
                    dest='action')
parser.add_argument('--config',
                    type=str,
                    required=True,
                    help='location of the json config file for preping snapshots',
                    dest='jsonConfig')
args = parser.parse_args()

log.debug("Parsed Args sucessfully")

if os.geteuid() != 0:
  exit("Error: Not running as root, exiting")

# The general format of the json file (Both from JSON or NixOS attr to JSON is this)
# -----------------------------------------------------------------------------------
# {
#   "archive folder": {
#     "hostname": {
#       "local cache of subvolumes from hostname": [
#         "@rootfs",
#         "@home",
#         "@log"
#       ]
#     }
#   }
# }
# -----------------------------------------------------------------------------------
# The archive folder and the local cache folder need to be on the same btrfs filesystem to work
# Also no volumes can have the same name per host (Basically the same requirements of btrbk)
# The latest subvolumes of each will get cloned into a subvolume for each host inside the archive folder
# That way Restic can scoop up everything by the archive folder
# Please don't use trailing slashes on folders, my program automatically adds them in


def js_r(filename: str):
  with open(filename) as f_in:
    return json.load(f_in)


btrbkLocations = js_r(args.jsonConfig)
log.debug("Load btrbk locations from json")

# Checks if folder exists and if it doesn't
# Make a btrfs subvol


def subvolCheckandCreation(subvol):
  if not os.path.exists(subvol):
    log.debug(subprocess.run(f"btrfs subvolume create \"{subvol}\"", shell=True, stdout=subprocess.DEVNULL))

# Dangerous, checks if subvol exists and removes it if it does


def subvolCheckandDeletion(subvol):
  if os.path.exists(subvol):
    log.debug(subprocess.run(f"btrfs subvolume delete \"{subvol}\"", shell=True, stdout=subprocess.DEVNULL))


def subvolSnapshot(source, destination):
  log.debug(subprocess.run(f"btrfs subvolume snapshot -r \"{source}\" \"{destination}\"", shell=True, stdout=subprocess.DEVNULL))


def prepareSnapshots():
  for archiveFolder in btrbkLocations:
    # Checks if the archive folder exists and if it doesn't create the subvolume
    subvolCheckandCreation(archiveFolder)
    for host in btrbkLocations[archiveFolder]:
      log.info(f"Working on host: {host}")
      hostArchiveFolder = f"{archiveFolder}/{host}"
      subvolCheckandCreation(hostArchiveFolder)
      for location in btrbkLocations[archiveFolder][host]:
        folderContents = os.listdir(location)
        for subvol in btrbkLocations[archiveFolder][host][location]:
          log.info(f"Working on: {location}/{subvol}")
          # Requires long timestamps in btrbk
          # For example if we are working on volume @home, an example full snapshot name would be
          # @home.20xx0101T0000
          # By removing the last 14 characters we get exact matches for the subvol we want
          filteredFolders = [item for item in folderContents if item[:-14] == subvol]
          # To be sure everything is sorted alphabetically
          # Probably not needed, but ehhh I want to be sure I'm taking the latest alphabetical subvol
          filteredFolders.sort()
          latestSubvol = filteredFolders[-1]
          log.debug(f"Newest Subvolume appears to be: {latestSubvol}")
          latestSubvolFullPath = f"{location}/{latestSubvol}"
          archiveSubvol = f"{hostArchiveFolder}/{subvol}"
          log.debug(f"Snapshotting data from \"{latestSubvolFullPath}\" to \"{archiveSubvol}\"")
          subvolCheckandDeletion(archiveSubvol)
          subvolSnapshot(latestSubvolFullPath, archiveSubvol)

# Quick cleanup after everything is said and done


def cleanupSnapshots():
  for archiveFolder in btrbkLocations:
    for host in btrbkLocations[archiveFolder]:
      hostArchiveFolder = f"{archiveFolder}/{host}"
      for location in btrbkLocations[archiveFolder][host]:
        for subvol in btrbkLocations[archiveFolder][host][location]:
          archiveSubvol = f"{hostArchiveFolder}/{subvol}"
          log.info(f"Cleaning up {archiveSubvol}")
          subvolCheckandDeletion(archiveSubvol)


if args.action == "prepare":
  prepareSnapshots()
elif args.action == "cleanup":
  cleanupSnapshots()
else:
  log.Error("How did you end up here without selecting anything?")
  exit()
