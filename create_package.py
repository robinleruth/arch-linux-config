import os

import sys

if len(sys.argv) != 2:
    print("Please give a package name as first argument")
    sys.exit()


dir_name = sys.argv[1]

path = os.path.join(os.getcwd(), dir_name)
print(path)
os.makedirs(path, exist_ok=True)
with open(os.path.join(path, '__init__.py'), 'w') as f:
    f.write('')

