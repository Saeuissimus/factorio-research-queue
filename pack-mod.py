#!/usr/bin/env python3

import zipfile, os, sys


archive_root = "research-queue_1.6.8"


with zipfile.ZipFile(archive_root + ".zip", "w") as archive:
  for root, dirs, files in os.walk("."):
    # print("Root: " + str(root) + " Dirs: " + str(dirs) + " Files: " + str(files))
    if ".git" in dirs:
      dirs.remove(".git")
    for file in files:
      if file == archive_root + ".zip":
        continue
      file_path = os.path.normpath(os.path.join(root, file))
      archive_path = os.path.normpath(os.path.join(archive_root, root, file))
      print("File path: " + str(file_path) + " Archive path: " + str(archive_path))
      archive.write(file_path, archive_path)

