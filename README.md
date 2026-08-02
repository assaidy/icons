# icons

Go library providing thousands of open-source SVG icons, with Tailwind-friendly class/id injection.

> **Note:** Icons are updated automatically, so to get the latest set depend on the current commit hash rather than a tag:
>
> ```
> go get -u github.com/assaidy/icons@<current-commit>
> ```

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

<!-- TABLE_START -->
| Import | Icons | Version | Source | License |
|---|---|---|---|---|
| `icons/lucide` | 2219 | 1.28.0 | [Lucide](https://github.com/lucide-icons/lucide) | MIT |
| `icons/materialicons/outlined` | 2122 | 0.14.15 | [Google Material Icons](https://github.com/google/material-design-icons) | Apache 2.0 |
| `icons/materialicons/rounded` | 2122 | 0.14.15 | [Google Material Icons](https://github.com/google/material-design-icons) | Apache 2.0 |
| `icons/materialicons/sharp` | 2122 | 0.14.15 | [Google Material Icons](https://github.com/google/material-design-icons) | Apache 2.0 |
| `icons/tablericons` | 5130 | v3.46.0 | [Tabler Icons](https://github.com/tabler/tabler-icons) | MIT |
<!-- TABLE_END -->

## License

This project is MIT licensed. Each icon library retains its original license.
