# Generate STL mesh output files from OpenSCAD source
# Brian K. White - b.kenyon.w@gmail.com

model = baggie-drying-tree
parts = arm bracket kit
sizes = 3 5 6

openscad = openscad-nightly
#openscad = openscad

.PHONY: all
all:
	set -x ;for s in $(sizes) ;do for p in $(parts) ;do \
		$(openscad) -D'part="'$${p}'"' -D'sd='$${s} -o $(model)_$${p}_$${s}mm.stl $(model).scad \
	;done ;done

.PHONY: clean
clean:
	rm -f *.stl *.png
