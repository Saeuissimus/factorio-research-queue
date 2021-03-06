#!/usr/bin/env python3

import zipfile, os, json

base_dir = os.path.dirname(os.path.abspath(__file__))
info_path = os.path.join(base_dir, "info.json")

with open(info_path) as info_file:
  info = json.load(info_file)

archive_root = info["name"] + "_" + info["version"]
archive_name = os.path.join(base_dir, archive_root + ".zip")

with zipfile.ZipFile(archive_name, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=9) as archive:
  for root, dirs, files in os.walk(base_dir):
    # print("Root: " + str(root) + " Dirs: " + str(dirs) + " Files: " + str(files))
    if ".git" in dirs:
      dirs.remove(".git")
    for file in files:
      file_path = os.path.normpath(os.path.join(root, file))
      if not os.path.isfile(file_path) or ".zip" in file or ".sh" in file or ".xcf" in file or file == ".gitignore" or file in __file__:
        continue
      archive_path = os.path.normpath(os.path.join(archive_root, os.path.relpath(os.path.join(root, file), start=base_dir)))
      print(f"File path: {file_path} Archive path: {archive_path}")
      archive.write(file_path, archive_path)

