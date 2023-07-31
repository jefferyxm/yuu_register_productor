###################################################################################
# Copyright 2019 seabeam@yahoo.com - Licensed under the Apache License, Version 2.0
# For more information, see LICENCE in the main folder
###################################################################################

class RegisterNode(object):
    def __init__(self, name='root'):
        object.__setattr__(self, 'name', name)
        object.__setattr__(self, 'items', {})
        object.__setattr__(self, 'attrs', {})
        
    def __iter__(self):
        return iter(self.items.items())
    
    def __setitem__(self, key, value):
        self.items[key] = value
        
    def __getitem__(self, key):
        return self.item[key]
    
    def __setattr__(self, key, value):
        self.attrs[key] = value
    
    def __getattr__(self, key):
        return self.attrs[key]
       
    def __delattr__(self, key):
        del self.attrs[key]

    def __delitem__(self, key):
        del self.items[key]

def walk(node, depth=0):
    for key, value in node:
        print('--'*depth+key)
        for k in value.attrs.keys():
            print("%s%s: %s" %('**'*(depth+1), k, value.attrs[k]))
        walk(value, depth+1)
        
