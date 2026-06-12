# icons

Go library providing thousands of open-source SVG icons, with Tailwind-friendly class/id injection.

## Usage

```go
import "github.com/assaidy/icons"
import "github.com/assaidy/icons/lucide"

// raw SVG
svg := lucide.User()

// with Tailwind classes
svg := lucide.User(icons.Params{Class: "w-6 h-6 text-red-500"})

// with id
svg := lucide.User(icons.Params{Id: "my-icon"})

// with both
svg := lucide.User(icons.Params{Class: "fill-blue-500", Id: "icon-1"})
```

## Packages

| Import | Icons | Source | License |
|---|---|---|---|
| `icons/lucide` | 1,819 | [Lucide](https://github.com/lucide-icons/lucide) | MIT |
| `icons/materialicons/outlined` | 2,122 | [Google Material Icons](https://github.com/google/material-design-icons) | Apache 2.0 |
| `icons/materialicons/rounded` | 2,122 | [Google Material Icons](https://github.com/google/material-design-icons) | Apache 2.0 |
| `icons/materialicons/sharp` | 2,122 | [Google Material Icons](https://github.com/google/material-design-icons) | Apache 2.0 |
| `icons/tablericons` | 5,093 | [Tabler Icons](https://github.com/tabler/tabler-icons) | MIT |

## License

This project is MIT licensed. Each icon library retains its original license.
