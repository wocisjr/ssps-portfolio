## Pro převod markdown na pdf
nainstalovat balíky
```
sudo apt-get install pandoc texlive-latex-base texlive-latex-recommended texlive-latex-extra ghostscript --no-install-recommends
```

pro převod zavolat
```
pandoc --pdf-engine=lualatex \
  -V colorlinks=true \
  -V linkcolor=blue \
  -V urlcolor=blue \
  -V citecolor=blue \
  -V geometry:margin=15mm \
  -o output.pdf source.md
```

případně na začátku markdown dokumentu přidat:
```
---
geometry: margin=15mm
colorlinks: true
linkcolor: blue
urlcolor: blue
citecolor: blue
---
```
a pak není potřeba přidávat `-V` parametry do `pandoc`

pro správné vytáhnutí obrázků z našich .md potřebujeme převést html tagy na latex img pomocí lua skriptu:
```
pandoc --pdf-engine=lualatex \
  --lua-filter=md-html-to-pdf.lua \
  --lua-filter=pagebreak.lua \
  --resource-path=. \
  source.md \
  -o docs/output.pdf \
```
