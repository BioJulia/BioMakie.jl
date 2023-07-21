module TestBioMakie

using LinearAlgebra
using Test

using BioStructures
using MIToS, MIToS.Information, MIToS.MSA, MIToS.Pfam, MIToS.SIFTS, MIToS.Utils
using ColorTypes, ColorSchemes, ImageCore, Colors
using GLMakie

using BioMakie
using BioMakie:
    defaultatom,
    defaultresidue,
    resletterdict,
    kideradict

firstkey(dict::AbstractDict) = first(keys(dict))
firstvalue(dict::AbstractDict) = first(values(dict))

@testset "Structure plotting" begin
    # BioStructures
    dir = joinpath(tempdir(),"structure")
    struc = retrievepdb("2VB1"; dir = dir)
    chn = collectchains(struc[1]["A"])
    resz = collectresidues(struc[1]["A"], standardselector)
    atms = collectatoms(struc[1]["A"], standardselector)
    struc_obs = Observable(struc)
    chn_obs = Observable(chn)
    resz_obs = Observable(resz)
    atms_obs = Observable(atms)
    @test size(resz_obs[]) == (129,)
    @test resz_obs[][end].name == "LEU"
    @test atms_obs[][end].coords == [-6.667, 21.245, 10.848]

    atmradii = atomradii(collectatoms(struc_obs[]))
    @test size(atmradii) == (2203,)
    @test atmradii[5] == 0.76f0
    @test atmradii[end] == 0.66f0
    atmradii = atomradii(collectatoms(chn_obs[]))
    @test size(atmradii) == (2203,)
    @test atmradii[5] == 0.76f0
    @test atmradii[end] == 0.66f0
    atmradii = atomradii(collectatoms(resz_obs[]))
    @test size(atmradii) == (1960,)
    @test atmradii[5] == 0.76f0
    @test atmradii[end] == 0.31f0
    atmradii = atomradii(collectatoms(atms_obs[]))
    @test size(atmradii) == (1960,)
    @test atmradii[5] == 0.76f0
    @test atmradii[end] == 0.31f0
    atmradii = atomradii(collectatoms(struc_obs[]); radiustype = :vdw)
    @test size(atmradii) == (2203,)
    @test atmradii[5] == 1.7f0
    @test atmradii[end] == 1.52f0
    atmradii = atomradii(collectatoms(chn_obs[]); radiustype = :vdw)
    @test size(atmradii) == (2203,)
    @test atmradii[5] == 1.7f0
    @test atmradii[end] == 1.52f0
    atmradii = atomradii(collectatoms(resz_obs[]); radiustype = :vdw)
    @test size(atmradii) == (1960,)
    @test atmradii[5] == 1.7f0
    @test atmradii[end] == 1.1f0
    atmradii = atomradii(collectatoms(atms_obs[]); radiustype = :vdw)
    @test size(atmradii) == (1960,)
    @test atmradii[5] == 1.7f0
    @test atmradii[end] == 1.1f0

    atmradius = atomradius(collectatoms(struc_obs[])[5])
    @test atmradius == 0.76f0
    atmradius = atomradius(collectatoms(chn_obs[])[5])
    @test atmradius == 0.76f0
    atmradius = atomradius(collectatoms(resz_obs[])[5])
    @test atmradius == 0.76f0
    atmradius = atomradius(collectatoms(atms_obs[])[5])
    @test atmradius == 0.76f0
    atmradius = atomradius(collectatoms(struc_obs[])[5]; radiustype = :vdw)
    @test atmradius == 1.7f0
    atmradius = atomradius(collectatoms(chn_obs[])[5]; radiustype = :vdw)
    @test atmradius == 1.7f0
    atmradius = atomradius(collectatoms(resz_obs[])[5]; radiustype = :vdw)
    @test atmradius == 1.7f0
    atmradius = atomradius(collectatoms(atms_obs[])[5]; radiustype = :vdw)
    @test atmradius == 1.7f0

    inspectlabel = getinspectorlabel(struc_obs[])
    str = inspectlabel(1,1,1)
    @test str[12:19] == "res: LYS"
    inspectlabel = getinspectorlabel(chn_obs[])
    str = inspectlabel(1,1,1)
    @test str[12:19] == "res: LYS"
    inspectlabel = getinspectorlabel(resz_obs[])
    str = inspectlabel(1,1,1)
    @test str[12:19] == "res: LYS"
    inspectlabel = getinspectorlabel(atms_obs[])
    str = inspectlabel(1,1,1)
    @test str[12:19] == "res: LYS"

    flabel = firstlabel(inspectlabel)
    @test flabel[12:19] == "res: LYS"

    atmcolors = atomcolors(struc_obs[])
    @test size(atmcolors) == (2203,)
    @test atmcolors[5] == :gray
    @test atmcolors[end] == :red
    atmcolors = atomcolors(chn_obs[])
    @test size(atmcolors) == (2203,)
    @test atmcolors[5] == :gray
    @test atmcolors[end] == :red
    atmcolors = atomcolors(resz_obs[])
    @test size(atmcolors) == (1960,)
    @test atmcolors[5] == :gray
    @test atmcolors[end] == :white
    atmcolors = atomcolors(atms_obs[])
    @test size(atmcolors) == (1960,)
    @test atmcolors[5] == :gray
    @test atmcolors[end] == :white

    atmcolors = atomcolors(struc_obs[]; colors = aquacolors)
    @test size(atmcolors) == (2203,)
    @test atmcolors[5] == RGB{Float64}(0.5,0.5,0.5)
    @test atmcolors[end] == RGB{Float64}(0.111,0.37,0.999)
    atmcolors = atomcolors(chn_obs[]; colors = aquacolors)
    @test size(atmcolors) == (2203,)
    @test atmcolors[5] == RGB{Float64}(0.5,0.5,0.5)
    @test atmcolors[end] == RGB{Float64}(0.111,0.37,0.999)
    atmcolors = atomcolors(resz_obs[]; colors = aquacolors)
    @test size(atmcolors) == (1960,)
    @test atmcolors[5] == RGB{Float64}(0.5,0.5,0.5)
    @test atmcolors[end] == RGB{Float64}(0.65,0.96,0.7)
    atmcolors = atomcolors(atms_obs[]; colors = aquacolors)
    @test size(atmcolors) == (1960,)
    @test atmcolors[5] == RGB{Float64}(0.5,0.5,0.5)
    @test atmcolors[end] == RGB{Float64}(0.65,0.96,0.7)

    atmcolors = atomcolors(struc_obs)
    @test size(atmcolors[]) == (2203,)
    @test atmcolors[][5] == :gray
    @test atmcolors[][end] == :red
    atmcolors = atomcolors(chn_obs)
    @test size(atmcolors[]) == (2203,)
    @test atmcolors[][5] == :gray
    @test atmcolors[][end] == :red
    atmcolors = atomcolors(resz_obs)
    @test size(atmcolors[]) == (1960,)
    @test atmcolors[][5] == :gray
    @test atmcolors[][end] == :white
    atmcolors = atomcolors(atms_obs)
    @test size(atmcolors[]) == (1960,)
    @test atmcolors[][5] == :gray
    @test atmcolors[][end] == :white

    atmcolors = atomcolors(struc_obs; colors = aquacolors)
    @test size(atmcolors[]) == (2203,)
    @test atmcolors[][5] == RGB{Float64}(0.5,0.5,0.5)
    @test atmcolors[][end] == RGB{Float64}(0.111,0.37,0.999)
    atmcolors = atomcolors(chn_obs; colors = aquacolors)
    @test size(atmcolors[]) == (2203,)
    @test atmcolors[][5] == RGB{Float64}(0.5,0.5,0.5)
    @test atmcolors[][end] == RGB{Float64}(0.111,0.37,0.999)
    atmcolors = atomcolors(resz_obs; colors = aquacolors)
    @test size(atmcolors[]) == (1960,)
    @test atmcolors[][5] == RGB{Float64}(0.5,0.5,0.5)
    @test atmcolors[][end] == RGB{Float64}(0.65,0.96,0.7)
    atmcolors = atomcolors(atms_obs; colors = aquacolors)
    @test size(atmcolors[]) == (1960,)
    @test atmcolors[][5] == RGB{Float64}(0.5,0.5,0.5)
    @test atmcolors[][end] == RGB{Float64}(0.65,0.96,0.7)

    # MIToS
    struc = MIToS.PDB.read("$(dir)/2VB1.pdb", MIToS.PDB.PDBFile);
    chn = MIToS.PDB.@residues struc model "1" chain "A" group "ATOM" residue All
    atms = MIToS.PDB.@atoms chn model "1" chain "A" group "ATOM" residue All atom All
    struc_obs = Observable(struc);
    chn_obs = Observable(chn);
    atms_obs = Observable(atms);
    rezsizes = [size(chn_obs[][i].atoms,1) for i in 1:size(chn_obs[],1)] 
    @test sum(rezsizes) == 2657
    @test length(struc) == 312

    acolors = atomcolors(struc; colors = aquacolors)
    @test length(acolors) == 2203
    acolors = atomcolors(chn_obs[]; colors = aquacolors)
    @test length(acolors) == 1960
    acolors_obs = atomcolors(chn_obs; colors = aquacolors)
    @test length(acolors_obs[]) == 1960
    acolors = atomcolors(struc; colors = aquacolors)
    @test acolors[1] == RGB{Float64}(0.472,0.211,0.499)
    acolors = atomcolors(chn_obs[]; colors = aquacolors)
    @test acolors[1] == RGB{Float64}(0.472,0.211,0.499)
    acolors = atomcolors(chn_obs; colors = aquacolors)
    @test acolors[][1] == RGB{Float64}(0.472,0.211,0.499)

    atmradii = atomradii(atms_obs[])
    @test size(atmradii) == (2657,)
    @test atmradii[5] == 0.76f0
    @test atmradii[end] == 0.31f0
    atmradii = atomradii(atms_obs[]; radiustype = :vdw)
    @test size(atmradii) == (2657,)
    @test atmradii[5] == 1.7f0
    @test atmradii[end] == 1.1f0

    atmradius = atomradius(atms_obs[][5])
    @test atmradius == 0.76f0
    atmradius = atomradius(atms_obs[][5]; radiustype = :vdw)
    @test atmradius == 1.7f0

    inspectlabel = getinspectorlabel(chn_obs[])
    str = inspectlabel(1,3,1)
    @test str[33:67] == "coordinates: [2.502, 7.339, 13.503]"
    inspectlabel = getinspectorlabel(atms_obs[])
    str = inspectlabel(1,3,1)
    @test str[33:67] == "coordinates: [2.502, 7.339, 13.503]"

    flabel = firstlabel(inspectlabel)
    @test flabel[33:67] == "coordinates: [1.984, 5.113, 14.226]"

    atmcolors = atomcolors(chn_obs[])
    @test size(atmcolors) == (1960,)
    @test atmcolors[5] == :gray
    @test atmcolors[end] == :white
    atmcolors = atomcolors(atms_obs[])
    @test size(atmcolors) == (2657,)
    @test atmcolors[5] == :gray
    @test atmcolors[end] == :white
    atmcolors = atomcolors(chn_obs[]; colors = aquacolors)
    @test size(atmcolors) == (1960,)
    @test atmcolors[5] == RGB{Float64}(0.5,0.5,0.5)
    @test atmcolors[end] == RGB{Float64}(0.65,0.96,0.7)
    atmcolors = atomcolors(atms_obs[]; colors = aquacolors)
    @test size(atmcolors) == (2657,)
    @test atmcolors[5] == RGB{Float64}(0.5,0.5,0.5)
    @test atmcolors[end] == RGB{Float64}(0.65,0.96,0.7)
    atmcolors = atomcolors(chn_obs)
    @test size(atmcolors[]) == (1960,)
    @test atmcolors[][5] == :gray
    @test atmcolors[][end] == :white
    atmcolors = atomcolors(atms_obs)
    @test size(atmcolors[]) == (2657,)
    @test atmcolors[][5] == :gray
    @test atmcolors[][end] == :white
    atmcolors = atomcolors(chn_obs; colors = aquacolors)
    @test size(atmcolors[]) == (1960,)
    @test atmcolors[][5] == RGB{Float64}(0.5,0.5,0.5)
    @test atmcolors[][end] == RGB{Float64}(0.65,0.96,0.7)
    atmcolors = atomcolors(atms_obs; colors = aquacolors)
    @test size(atmcolors[]) == (2657,)
    @test atmcolors[][5] == RGB{Float64}(0.5,0.5,0.5)
    @test atmcolors[][end] == RGB{Float64}(0.65,0.96,0.7)
end

@testset "MSA plotting" begin
    # MIToS
    msa1 = MIToS.MSA.read("./docs/src/assets/pf00062.stockholm.gz",Stockholm)
    @test size(msa1) == (1733, 123)
    @test length(msa1.annotations.sequences) == 1748
    plotdata = plottingdata(msa1)
    msamatrix = plotdata[:matrix]
    @test size(msamatrix) == (1733, 123)
    matrixvals = msavalues(msamatrix)
    @test firstkey(kideradict) == "A"
    @test firstvalue(kideradict) == [-1.56, -1.67, -0.97, -0.27, -0.93, -0.78, -0.2, -0.08, 0.21, -0.48]
end

end