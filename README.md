# vai.nvim

Jump to any visible line with two keystrokes. No line numbers needed.

## How it works

Press `\` → type any two-letter combo → jump to that line.

```
ff → line +6
jj → line -6
as → line +7
jk → line -7
...
```

**The easiest combos land on the most useful lines:**
- Double letters (`ff`, `jj`, `dd`) → sweet spot (±6-15 lines)
- Finger rolls (`as`, `sd`, `jk`, `kl`) → sweet spot
- Other combos → close and far lines

## Installation

```lua
-- lazy.nvim
{
  'johnpmitsch/vai.nvim',
  config = function()
    require('vai').setup()
  end,
}
```

## Usage

| Keys | Action |
|------|--------|
| `\ff` | Jump to line +6 |
| `d\ff` | Delete to line +6 |
| `y\jj` | Yank to line -6 |
| `v\as` | Visual select to line |

Works in normal, visual, and operator-pending modes.

## Design

**Defaults ptimized for speed:**
- Only 19 easy letters: `a s d f g j k l w e r t y u i o c v n`
- Dropped hard-to-reach: `q z x b m p h`
- hundreds of combos, prioritized by typing ease
- Rotating pastel colors for easy visual tracking

**Smart mapping:**
- Easiest combos → most common jump distances (±6-15 lines)
- Mistyped key = nearby line (QWERTY-aware)

## Configuration

```lua
require('vai').setup({
  trigger = '\\',           -- trigger key
  sweet_spot_start = 6,     -- easiest combos start here
  sweet_spot_end = 15,      -- easiest combos end here
  labels = {                -- customize letters (e.g., for Dvorak)
    'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l',
    'w', 'e', 'r', 't', 'y', 'u', 'i', 'o',
    'c', 'v', 'n',
  },
})
```

## License

MIT