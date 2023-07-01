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

# All writing is done to one temporary file which is removed at the end
# temp_filename, io = mktemp()
# close(io)

@testset "Structure plotting" begin
    # BioStructures
    # dir = joinpath(tempdir(),"structure")
    struc = retrievepdb("2VB1")
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
    inspectlabel = getinspectorlabel(struc_obs)
    str = inspectlabel(1,1,1)
    @test str[12:19] == "res: LYS"
    inspectlabel = getinspectorlabel(chn_obs)
    str = inspectlabel(1,1,1)
    @test str[12:19] == "res: LYS"
    inspectlabel = getinspectorlabel(resz_obs)
    str = inspectlabel(1,1,1)
    @test str[12:19] == "res: LYS"
    inspectlabel = getinspectorlabel(atms_obs)
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
    
    # # MIToS
    # filename = downloadpfam("PF00062"; filename = "$(dir)/PF00062.stockholm.gz")
    # msa1 = MIToS.MSA.read("$(dir)/PF00062.stockholm.gz",Stockholm, generatemapping=true, useidcoordinates=true)
    # plotdata = plottingdata(msa1)
    # msamatrix = plotdata["matrix"]
    # xlabel = plotdata["xlabels"]
    # ylabel = plotdata["ylabels"]
    # @test typeof(msamatrix) <: AbstractArray{String}
    # @test typeof(xlabel) <: AbstractArray{String}
    # @test typeof(ylabel) <: AbstractArray{String}

    # # pdbfile = MIToS.PDB.downloadpdb("2vb1"; filename = "$(dir)/2vb1.pdb")     # download problems with ".gz"
    # res_2vb1 = MIToS.PDB.read("$(dir)/2vb1.pdb", MIToS.PDB.PDBFile)
    # chn = MIToS.PDB.@residues res_2vb1 model "1" chain "A" group "ATOM" residue All
    # chn_obs = Observable(chn);
    # reszizes = [size(chn[i].atoms,1) for i in 1:size(chn,1)] 
    # @test sum(reszizes) == 2657
    # @test length(res_2vb1) == 312

    # acolors = atomcolors(res_2vb1; colors = aquacolors)
    # @test length(acolors) == 2203
    # acolors = atomcolors(chn_obs[]; colors = aquacolors)
    # @test length(acolors) == 1960
    # acolors_obs = atomcolors(chn_obs; colors = aquacolors)
    # @test length(acolors_obs[]) == 1960
    # acolors = atomcolors(res_2vb1; colors = aquacolors)
    # @test acolors[1] == RGB{Float64}(0.472,0.211,0.499)
    # acolors = atomcolors(chn_obs[]; colors = aquacolors)
    # @test acolors[1] == RGB{Float64}(0.472,0.211,0.499)
    # acolors = atomcolors(chn_obs; colors = aquacolors)
    # @test acolors[][1] == RGB{Float64}(0.472,0.211,0.499)

    # rcolors = rescolors(chn)
    # @test rcolors[1] == :orange
    # rcolors = rescolors(res_2vb1)
    # @test rcolors[][1] == :orange
    # @test length(rescolors(res_2vb1)) == 1960

    # Delete temporary directory
    # rm(dir, recursive=true, force=true)
end

end