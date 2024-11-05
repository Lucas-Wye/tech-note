$out_dir="out";

$preview_mode=1;
$bibtex_use = 1.5;

# FOR xelatex
$pdf_mode=5;
$xelatex = "xelatex -file-line-error -halt-on-error -interaction=nonstopmode -no-pdf -synctex=1 %O %S";
$xdvipdfmx = "xdvipdfmx -q -E -o %D %O %S";

$clean_ext = 'thm bbl hd loe synctex.gz xdv run.xml';
$makeindex = 'makeindex -s gind.ist %O -o %D %S';

@default_files=('*.tex')