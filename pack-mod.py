#!/usr/bin/env python3

import zipfile, os


archive_root = "research-queue_1.6.8"


with zipfile.ZipFile(archive_root + ".zip", "w", compression=zipfile.ZIP_DEFLATED, compresslevel=9) as archive:
  for root, dirs, files in os.walk("."):
    # print("Root: " + str(root) + " Dirs: " + str(dirs) + " Files: " + str(files))
    if ".git" in dirs:
      dirs.remove(".git")
    for file in files:
      file_path = os.path.normpath(os.path.join(root, file))
      if not os.path.isfile(file_path) or ".zip" in file or file in __file__:
        continue
      archive_path = os.path.normpath(os.path.join(archive_root, root, file))
      print("File path: " + str(file_path) + " Archive path: " + str(archive_path))
      archive.write(file_path, archive_path)

