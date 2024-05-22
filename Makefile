FILE = TechNote
TYP = $(wildcard src/*.typ) $(FILE).typ
OUT = $(FILE).pdf

all: $(OUT)

$(OUT): $(TYP)
	typst compile $(FILE).typ $@

view: $(OUT)
	zathura $< &
