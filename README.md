# Grunt Architect
Populate a JSON file right from your HTML comments. Use json, yaml or cson to store your data.

```html
<div>
    <!-- architect
    some description
    ---
        path: foo
        baz: baz
        bar: bar
    -->
</div>
```

and output that to blueprints.json

```json
{
    "foo": {
        "baz": "baz",
        "bar": "bar"
    }
}
```


## Grunt setup

```coffeescript
architect:
  all:
    files: {
      'blueprints.json': ['fileA.html', 'fileB.html']
    }
```

or with custom options

```coffeescript
architect:
  all:
    options: {
        parser: 'yaml'
        keyword: 'mycustomkeyword'
        template: {
            foo: {
              baz: "baz"
            }
        }
    }
    files: {
      'blueprints.json': ['fileA.html', 'fileB.html']
    }
```

__parser__ `'yaml'`<br>
yaml | cson | json.

__keyword__ `architect`<br>
keyword used to collect comments.

__template__ `{}`<br>
json object to use as a basis for the blueprints file.



## Architect

Make sure you write valid yaml, json or cson. Yaml is probably easiest to write. 

Everything you write after keyword and before the beginning of your object will be ignored. Might be a nice place for some descriptive piece of text (let's call it a comment comment).

### Variables
__path__ (required) <br>
Use the `path` variable to specify a json-path. This is the dot-notated path to where your object will be stored in the outputted json.

```yaml
<!-- architect
I am a great grandchild
---
    path: family.child.grandchild
    greatgrandchild1:
        description: 'im a great-grandchild'
-->
```

So when path is `family.child.grandchild`, your object will be placed at the ...

```js
{
    "family": {
        "child": {
            "grandchild": {
                ...
            }
        }
    }
}
```

An object will be created for every key that doesn't exist. 