Ruby Object Diff
----------------

Have you ever faced with a 2 screen worth of `assertion failed` showing 2 massive objects that are not equal? And then you couldn't find where they differ? This tool might be for you.

## Usage

```ruby
puts ObjDiff[expected, actual]
```

Example output:

```
Diff on value at _[:user].badges[0][1]:
  < 1
  !=
  > 2
```
