import os

import sys

if len(sys.argv) < 2:
    print("Please give a file name as first argument")
    sys.exit()

import re

REG = r"(.*?)_([a-zA-Z])"

def camel_upper(match):
    return match.group(1)[0].upper() + match.group(1)[1:] + match.group(2).upper()


file_name = sys.argv[1]

file_name_without_py = os.path.splitext(file_name)[0]

class_name = re.sub(REG, camel_upper, file_name_without_py, 0) if '_' in file_name_without_py else file_name_without_py.capitalize()

if ".js" in file_name:
    file_name = class_name + ".js"
    class_type = sys.argv[2] if len(sys.argv) == 3 else None
    if class_type and class_type == 'model':
        with open(os.path.join(os.getcwd(), file_name), 'w') as f:
            f.write(f"'use strict';\n\nvar app = app || {{}};\n\napp.{class_name} = Backbone.Model.extend({{\n}});\n")
    elif class_type and class_type == 'view':
        template_name = file_name_without_py + "_template"
        with open(os.path.join(os.getcwd(), file_name), 'w') as f:
            f.write(f"'use strict';\n\nvar app = app || {{}};\n\napp.{class_name} = Backbone.View.extend({{\n   template: _.template($('#" + template_name + "').html()),\n   tagName: 'div',\n   className: '',\n   events: {{\n   }},\n   initialize: function(){{\n       this.listenTo(this.model, 'change', this.render);\n       this.listenTo(this.model, 'destroy', this.remove);\n       this.listenTo(this.model, 're-render', this.render);\n   }},\n   render: function(){{\n       this.$el.html(this.template(this.model.toJSON()));\n       return this;\n   }},\n}});\n")
        with open(os.path.join(os.getcwd(), file_name_without_py + '_template.html'), 'w') as f:
            f.write("<link rel='stylesheet' type='text/css' href='" + file_name_without_py + "_style.css" + "'>\n<script type='text/template' id='" + template_name + "></script>")
        with open(os.path.join(os.getcwd(), file_name_without_py + '_style.css'), 'w') as f:
            f.write("\n")
    elif class_type and class_type == 'collection':
        with open(os.path.join(os.getcwd(), file_name), 'w') as f:
            f.write(f"'use strict';\n\nvar app = app || {{}};\n\napp.{class_name} = Backbone.Collection.extend({{\n   model: '',\n   url: ''\n}});\n")
    else:
        with open(os.path.join(os.getcwd(), file_name), 'w') as f:
            f.write(" ")
    sys.exit()

if ".h" in file_name:
    file_name = class_name + ".h"
    file_name_without_py = file_name_without_py.upper()
    with open(os.path.join(os.getcwd(), file_name), 'w') as f:
        f.write(f"#ifndef {file_name_without_py}_H\n#define {file_name_without_py}_H\n \n \n class {class_name}{{\n    public:\n        {class_name}();\n        ~{class_name}();\n    private:\n }};\n \n \n \n#endif\n ")
    sys.exit()

if 'test' in file_name:
    with open(os.path.join(os.getcwd(), file_name), 'w') as f:
        f.write('import unittest\n\n\n')
        f.write(f'class {class_name}(unittest.TestCase):\n')
        f.write('    def setUp(self):\n        pass\n\n')
        f.write('    def tearDown(self):\n        pass\n\n')
        f.write('    def test(self):\n        pass\n\n\n')
        f.write("if __name__ == '__main__':\n")
        f.write('    unittest.main(verbosity=2)\n')
else:
    with open(os.path.join(os.getcwd(), file_name), 'w') as f:
        f.write(f'class {class_name}:\n')
        f.write('    pass\n')

