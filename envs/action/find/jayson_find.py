import argparse
import os
import regex as re

def parse_arguments():
  # 获取调用脚本时的当前工作目录
  execution_dir = os.getcwd()
  parser = argparse.ArgumentParser(description="Find files with a specific extension.")
  parser.add_argument("--directory", "-d", dest = "directory", default= execution_dir, type=str, help="Directory to search in.")
  parser.add_argument("--exclude-directory", "-ed", dest = "exclude_directory", nargs='+', default=[], type=str, help="Exclude directories from search.")
  parser.add_argument("--extension", "-e", default=[], nargs='+', type=str, help="File extension to look for (e.g., .py, .cpp, .h).")
  parser.add_argument("--recursive", "-r", action="store_false", help="Search recursively in subdirectories.")
  parser.add_argument("--name", "-n", type=str, help="File name to look for.")
  parser.add_argument("--context", "-c", type=str, help="Show context around matches.")

  return parser.parse_args()

def find_files(directory, name, extension, exclude_dirs, recursive, context):
  indent = 0
  for root, dirs, files in os.walk(directory):
    # 排除指定的目录
    dirs[:] = [d for d in dirs if d not in exclude_dirs]


    for file in files:
      if file == name :
        file_path = os.path.join(root, file)
        print(f'Searching in: {root}')
        print(f'{" " * (indent+2)}🤗 Found: {file_path}')
        if context:
          match_context_in_file(root, file_path, context, indent + 4)
      elif extension and any(file.endswith(ext) for ext in extension):
        file_path =  os.path.join(root, file)
        if context:
          match_context_in_file(root, file_path, context, indent + 4)

def match_context_in_file(root, file_path, search_string, indent):
  split = False
  first_match = True
  with open(file_path, 'r', encoding='utf-8') as f:
    for line_num, line in enumerate(f, start=1):
      res = re.search(search_string, line)
      if res and first_match:
        print(f'Searching in: {root}')
        first_match = False
      if res:
        split = True
        print(f'{" " * indent}🤗 Matches in {file_path}:{line_num}:')
        print(f'{" " * (indent+2)}|--😊 Matches is: {line}')

  if split:
    print("-" * 40)

if __name__ == "__main__":
  parse_arg = parse_arguments()

  if parse_arg.name or parse_arg.context:
    find_files(
      parse_arg.directory,
      parse_arg.name,
      parse_arg.extension,
      parse_arg.exclude_directory,
      parse_arg.recursive,
      parse_arg.context
    )
  else:
    print("😂Please provide a file name to search for using --name or -n option.😂")