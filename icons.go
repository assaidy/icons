package icons

import "strings"

type Params struct {
	Class string
	Id    string
}

func ApplyParams(icon string, params ...Params) string {
	if len(params) == 0 {
		return icon
	}
	p := params[0]
	if p.Class == "" && p.Id == "" {
		return icon
	}
	if p.Class != "" {
		icon = strings.Replace(icon, "<svg", `<svg class="`+p.Class+`"`, 1)
	}
	if p.Id != "" {
		icon = strings.Replace(icon, "<svg", `<svg id="`+p.Id+`"`, 1)
	}
	return icon
}
