# vai.nvim

Line jumping without numbers. Jump to any visible line with 3 keystrokes.

## The Problem

Relative line numbers require reaching for the number row, which is slow and error-prone if you don't have the muscle memory for it.

## The Solution

Press `\` to show labels on all visible lines. Type the group label, then the line label. Done.

```
Before pressing \:

  14 │ some code
  15 │ more code
  16 │ cursor here
  17 │ target line
  18 │ another line

After pressing \:

 [a] │ some code        ← group 'a' (lines -13 to -1)
 [a] │ more code
     │ cursor here      ← no label
 [a] │ target line      ← group 'a' (lines +1 to +13)
 [a] │ another line

After pressing 'a' (now showing lines within group):

 [a] │ some code        ← line -13 (farthest above)
 [s] │ ...              ← line -12
 ...
 [e] │ ...              ← line -2
 [r] │ more code        ← line -1 (closest above)
     │ cursor here
 [a] │ target line      ← line +1 (closest below)
 [s] │ another line     ← line +2
 ...
 [e] │ ...              ← line +12
 [r] │ ...              ← line +13 (farthest below)

Press 'a' to jump to line +1, 'r' to jump to line -1.
```

## Installation

### lazy.nvim

```lua
{
  'yourusername/vai.nvim',
  config = function()
    require('vai').setup()
  end,
}
```

### packer.nvim

```lua
use {
  'yourusername/vai.nvim',
  config = function()
    require('vai').setup()
  end,
}
```

## Configuration

```lua
require('vai').setup({
  -- Trigger key (default: \)
  trigger = '\\',

  -- Labels in priority order (left hand home row first)
  -- First 13 used for groups, first 13 used for lines within groups
  labels = {
    'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', 'q', 'w', 'e', 'r',
    't', 'y', 'u', 'i', 'o', 'p', 'z', 'x', 'c', 'v', 'b', 'n', 'm',
  },

  -- Highlight groups
  highlights = {
    label = 'VaiLabel',
    dim = 'VaiDim',
  },
})
```

## Usage

### Normal Mode

```
\aa  → jump to line +1 (closest below)
\ar  → jump to line -1 (closest above)
\as  → jump to line +2
\sa  → jump to line +14
```

### Operator Pending Mode

```
d\aa  → delete from cursor through line +1 (linewise)
y\sa  → yank from cursor through line +14
c\ar  → change from cursor through line -1
```

### Visual Mode

```
v\aa  → extend selection to line +1
V\sa  → extend linewise selection to line +14
```

## Coverage

- 13 groups × 13 lines = 169 lines per direction
- Total: 338 visible lines covered

More than enough for any screen.

## Design Decisions

1. **Single trigger** - `\` shows labels both above and below cursor
2. **Same labels for groups and lines** - muscle memory transfers
3. **Left hand first** - trigger is `\` (right hand), labels are left hand home row
4. **Always 3 keystrokes** - no ambiguity, instant response
5. **Mirrored groups, split labels** - group 'a' appears above and below, but line labels are distributed so 'a' = below closest, 'r' = above closest
6. **No shift required** - all lowercase

## License

MIT