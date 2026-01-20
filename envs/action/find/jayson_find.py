import argparse
import os
import regex as re
from rich.console import Console
from rich.tree import Tree

console = Console()
class file_info:
  def __init__(self, path, name):
    self.path = path
    self.name = name

class file_list:
  def __init__(self):
    self.files : dict[str, list[file_info]] = {}

  def add_file(self, file: file_info):
    if file.path not in self.files:
      self.files[file.path] = []
    self.files[file.path].append(file)


def build_correct_directory(arg_dir : str)->str:
  if arg_dir is not None and arg_dir.find('./') == 0:
    arg_dir = os.getcwd() + '/' + arg_dir[2:]
  elif arg_dir is not None and arg_dir.find('~/') == 0:
    arg_dir = os.path.expanduser('~') + '/' + arg_dir[2:]
  elif arg_dir is None:
    arg_dir = os.getcwd()

  if not os.path.isdir(arg_dir):
    raise argparse.ArgumentTypeError(f"Directory {arg_dir} does not exist.")
  return arg_dir

def parse_arguments():
  # 获取调用脚本时的当前工作目录
  execution_dir = os.getcwd()
  parser = argparse.ArgumentParser(description="Find files with a specific extension.")
  parser.add_argument("--directory", "-d", dest = "directory", default = None, type=str, help="Directory to search in.")
  parser.add_argument("--exclude-directory", "-ed", dest = "exclude_directory", nargs='+', default=[], type=str, help="Exclude directories from search.")
  parser.add_argument("--extension", "-e", default=[], nargs='+', type=str, help="File extension to look for (e.g., .py, .cpp, .h).")
  parser.add_argument("--recursive", "-r", action="store_false", help="Search recursively in subdirectories.")
  parser.add_argument("--name", "-n", type=str, help="File name to look for.")
  parser.add_argument("--context", "-c", type=str, help="Show context around matches.")
  parser.add_argument("--max-exclude", "-me", action="store_false", help="Exclude maximum directories.")

  return parser.parse_args()

def build_tree(paths, root):
    tree = {}
    root_parts = root.rstrip('/').split('/')
    root_len = len(root_parts)
    for path in paths:
        parts = path.rstrip('/').split('/')
        rel_parts = parts[root_len:]
        current = tree
        for part in rel_parts[:-1]:
            if part not in current:
                current[part] = {}
            current = current[part]
        current[rel_parts[-1]] = None
    return tree

def print_tree(tree, name, console, directory):
    root_tree = Tree(f"📁 {name}", style="bold blue")

    def add_to_tree(node, subtree, prefix):
        for item in sorted(subtree.keys()):
            if subtree[item] is None:
                full_path = os.path.join(prefix, item)
                node.add(f"📄 {item} : {full_path}", style="green")
            else:
                # 尝试合并直线目录路径，但不合并到文件
                path_parts = [item]
                current = subtree[item]
                while isinstance(current, dict) and len(current) == 1:
                    next_item = list(current.keys())[0]
                    if current[next_item] is None:
                        # 遇到文件，停止合并，添加目录
                        full_path = '/'.join(path_parts)
                        full_dir_path = os.path.join(prefix, full_path)
                        child = node.add(f"📁 {full_path}", style="blue")
                        add_to_tree(child, current, full_dir_path)
                        break
                    else:
                        path_parts.append(next_item)
                        current = current[next_item]
                else:
                    # 不能合并或遇到分支，添加目录
                    full_path = '/'.join(path_parts)
                    full_dir_path = os.path.join(prefix, full_path)
                    child = node.add(f"📁 {full_path}", style="blue")
                    add_to_tree(child, current, full_dir_path)

    add_to_tree(root_tree, tree, directory)
    console.print(root_tree)

def find_files(directory, name, extension, exclude_dirs, recursive, context, max_exclude):

  indent = 0
  count = 0

  file_infos = file_list()

  paths = []  # 收集匹配的文件路径

  for root, dirs, files in os.walk(directory):

    if root == directory:
        # 只在顶层排除指定的目录
        dirs[:] = [d for d in dirs if d not in exclude_dirs]

    for file in files:
      if file == name :

        file_path = os.path.join(root, file)
        paths.append(file_path)

        if context:
          match_context_in_file(root, file, file_infos, context, indent + 4)
        else:
          file_infos.add_file(file_info(root, file))

      elif extension and any(file.endswith(ext) for ext in extension):

        file_path = os.path.join(root, file)
        paths.append(file_path)

        if context:
          match_context_in_file(root, file, file_infos, context, indent + 4)
        else:
          file_infos.add_file(file_info(root, file))

  if not context and paths:
    tree = build_tree(paths, directory)
    root_name = os.path.basename(directory)
    print_tree(tree, root_name, console, directory)
    console.print(f"[bold]Total found: {len(paths)}[/bold]")
  elif context:
    # 对于 context 模式，统计唯一文件数
    unique_files = set()
    for path, files in file_infos.files.items():
      for file in files:
        unique_files.add(os.path.join(file.path, file.name))
    console.print(f"[bold]Total found: {len(unique_files)}[/bold]")

def match_context_in_file(root, file, file_infos, search_string, indent):
  split = False
  first_match = True
  file_path =  os.path.join(root, file)
  with open(file_path, 'r', encoding='utf-8') as f:
    for line_num, line in enumerate(f, start=1):
      res = re.search(search_string, line)
      if res and first_match:
        console.print(f'Searching in: {root}')
        first_match = False
      if res:
        split = True
        file_infos.add_file(file_info(root, file))
        # console.print(f'{" " * indent}🤗 Matches in {file_path}:{line_num}:')
        # console.print(f'{" " * (indent+2)}|--😊 Matches is: {line}')

  if split:
    console.print("-" * 40)

if __name__ == "__main__":
  parse_arg = parse_arguments()

  parse_arg.directory = build_correct_directory(parse_arg.directory)

  find_files(
    parse_arg.directory,
    parse_arg.name,
    parse_arg.extension,
    parse_arg.exclude_directory,
    parse_arg.recursive,
    parse_arg.context,
    parse_arg.max_exclude
  )