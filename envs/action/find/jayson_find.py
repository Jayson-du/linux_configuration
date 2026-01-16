import argparse
import os

def parse_arguments():
  execution_dir = os.getcwd()  # 获取调用脚本时的当前工作目录
  parser = argparse.ArgumentParser(description="Find files with a specific extension.")
  parser.add_argument("--directory", "-d", dest = "directory", default= execution_dir, type=str, help="Directory to search in.")
  parser.add_argument("--exclude-directory", "-ed", dest = "exclude_directory", nargs='+', default=[], type=str, help="Exclude directories from search.")
  parser.add_argument("--extension", "-e", type=str, help="File extension to look for (e.g., .py, .cpp, .h).")
  parser.add_argument("--recursive", "-r", action="store_false", help="Search recursively in subdirectories.")
  parser.add_argument("--context", "-c", type=str, help="Show context around matches.")

  return parser.parse_args()

def find_files_with_extension(directory, extension, exclude_dirs, recursive, context):
  for root, dirs, files in os.walk(directory):
    # 排除指定的目录
    dirs[:] = [d for d in dirs if d not in exclude_dirs]

    for file in files:
      if file.endswith(extension):
        file_path = os.path.join(root, file)
        print(f"Found: {file_path}")

        if context:
          with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
            lines = f.readlines()
            for i, line in enumerate(lines):
              if context in line:
                start = max(0, i - 2)
                end = min(len(lines), i + 3)
                print(f"Context in {file_path} (line {i + 1}):")
                for j in range(start, end):
                  print(f"{j + 1}: {lines[j].rstrip()}")
                print("-" * 40)

    if not recursive:
      break

if __name__ == "__main__":
  parse_arg = parse_arguments()
  find_files_with_extension(
    parse_arg.directory,
    parse_arg.extension,
    parse_arg.exclude_directory,
    parse_arg.recursive,
    parse_arg.context
  )