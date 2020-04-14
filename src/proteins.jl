# this file will probably change drastically soon

pdbid = Node("3P08")
pdbdescript = @lift [getpdbdescription($pdbid) |> keys |> collect, getpdbdescription($pdbid) |> values |> collect] |> combinedims
prot = @lift begin BioStructures.downloadpdb($pdbid; pdb_dir = "$(pdbdir())"); BioStructures.readpdb($pdbid; pdb_dir = "$(pdbdir())") end
chainn = Node("A")
atms = @lift collectatoms($prot[$chainn], standardselector)
internaldists = @lift internaldistances($atms)
contacts = @lift ContactMap($atms, 8.0).data
atmcolors = @lift [aquacolors[element(x)] for x in $atms]
# kfcolors = @lift [elecolors2[element(x)] for x in $atms]
atmradii = @lift [vanderwaals[element(x)] for x in $atms]
atmcoords = @lift coordarray($atms) |> _t
residues = @lift collectresidues($atms)
resids = @lift resid.($residues)
atmdicts = @lift BioStructures.atoms.($residues)

scene, layout = layoutscene(resolution = (1000,1000))
sc_left = layout[1:24,1:8] = GridLayout(24,8)
sc_middle = layout[1:24,9:16] = GridLayout(24,8)
sc_right = layout[1:24,17:24] = GridLayout(24,8)
