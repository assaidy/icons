package main

import (
	"bytes"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"sort"
	"strings"
	"unicode"
)

type packageDef struct {
	outPkg string
	outDir string
}

type iconDef struct {
	name     string
	filename string
}

func main() {
	repoRoot := "."

	pkgs := []packageDef{
		{outPkg: "lucide", outDir: "lucide"},
		{outPkg: "outlined", outDir: "materialicons/outlined"},
		{outPkg: "rounded", outDir: "materialicons/rounded"},
		{outPkg: "sharp", outDir: "materialicons/sharp"},
		{outPkg: "tablericons", outDir: "tablericons"},
	}

	for _, pkg := range pkgs {
		if err := generatePackage(repoRoot, pkg); err != nil {
			log.Fatalf("Error generating package %s: %v", pkg.outDir, err)
		}
	}
	fmt.Println("All packages generated successfully.")
}

func generatePackage(repoRoot string, pkg packageDef) error {
	outDir := filepath.Join(repoRoot, pkg.outDir)

	entries, err := os.ReadDir(outDir)
	if err != nil {
		return fmt.Errorf("cannot read dir %s: %w", outDir, err)
	}

	var icons []iconDef
	for _, entry := range entries {
		if entry.IsDir() || !strings.HasSuffix(entry.Name(), ".svg") {
			continue
		}
		name := svgNameToGoName(strings.TrimSuffix(entry.Name(), ".svg"))
		icons = append(icons, iconDef{name: name, filename: entry.Name()})
	}

	if len(icons) == 0 {
		return fmt.Errorf("no SVG files found in %s", outDir)
	}

	sort.Slice(icons, func(i, j int) bool {
		return icons[i].name < icons[j].name
	})

	return writeGoFile(outDir, pkg.outPkg, icons)
}

func svgNameToGoName(name string) string {
	parts := strings.FieldsFunc(name, func(r rune) bool {
		return r == '-' || r == '_' || r == ' ' || r == '.'
	})
	for i, p := range parts {
		if len(p) > 0 {
			r := []rune(p)
			r[0] = unicode.ToUpper(r[0])
			parts[i] = string(r)
		}
	}
	result := strings.Join(parts, "")
	if len(result) > 0 && unicode.IsDigit(rune(result[0])) {
		result = "Icon" + result
	}
	return result
}

func writeGoFile(outDir string, pkgName string, icons []iconDef) error {
	var buf bytes.Buffer

	buf.WriteString("// Code automatically generated. DO NOT EDIT.\n\n")
	fmt.Fprintf(&buf, "package %s\n\n", pkgName)
	buf.WriteString("import (\n\t_ \"embed\"\n\n\t\"github.com/assaidy/icons\"\n)\n\n")

	for _, icon := range icons {
		fmt.Fprintf(&buf, "//go:embed %s\n", icon.filename)
		fmt.Fprintf(&buf, "var _%s string\n", icon.name)
		fmt.Fprintf(&buf, "func %s(params ...icons.Params) string {\n\treturn icons.ApplyParams(_%s, params...)\n}\n\n", icon.name, icon.name)
	}

	content := strings.TrimRight(buf.String(), "\n")

	outFile := filepath.Join(outDir, "icons.go")
	if err := os.WriteFile(outFile, []byte(content+"\n"), 0644); err != nil {
		return fmt.Errorf("error writing %s: %w", outFile, err)
	}
	fmt.Printf("Generated %s (%d icons)\n", outFile, len(icons))
	return nil
}
