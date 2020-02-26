import os

import sys

if len(sys.argv) != 2:
    print("Please give a file name as first argument")
    sys.exit()

import re

REG = r"(.*?)_([a-zA-Z])"

def camel_upper(match):
    return match.group(1)[0].upper() + match.group(1)[1:] + match.group(2).upper()


file_name = sys.argv[1]

file_name_without_py = os.path.splitext(file_name)[0]

class_name = re.sub(REG, camel_upper, file_name_without_py, 0) if '_' in file_name_without_py else file_name_without_py.capitalize()

if 'test' in file_name:
    with open(os.path.join(os.getcwd(), file_name), 'w') as f:
        f.write('import unittest\n\n\n')
        f.write(f'class {class_name}(unittest.TestCase):\n')
        f.write('    def setUp(self):\n        pass\n\n')
        f.write('    def tearDown(self):\n        pass\n\n')
        f.write('    def test(self):\n        pass\n\n')
        f.write("if __name__ == '__main__':\n")
        f.write('    unittest.main(verbosity=2)\n')
else:
    with open(os.path.join(os.getcwd(), file_name), 'w') as f:
        f.write(f'class {class_name}:\n')
        f.write('    pass\n')

