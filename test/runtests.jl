module TestBioMakie

using LinearAlgebra
using Test

using Aqua
using BioStructures
using MIToS, MIToS.Information, MIToS.MSA, MIToS.Pfam, MIToS.SIFTS, MIToS.Utils
using ColorTypes, ColorSchemes, ImageCore, Colors
# using GLMakie
# GLMakie.activate!()

using BioMakie
using BioMakie:
    defaultatom,
    defaultresidue,
    resletterdict,
    kideradict

# All writing is done to one temporary file which is removed at the end
temp_filename, io = mktemp()
close(io)

Aqua.test_all(BioMakie; ambiguities=(recursive=false))

@testset "Structure plotting" begin
    # BioStructures
    dir = joinpath(tempdir(),"structure")
    struc = retrievepdb("2VB1", dir=dir)
    chn = struc[1]["A"]
    chn_obs = Observable(chn)
    resz = collectresidues(struc[1]["A"], standardselector)
    atms = collectatoms(struc[1]["A"], standardselector)
    struc_obs = Observable(struc)
    resz_obs = Observable(resz)
    atms_obs = Observable(atms)

    acolors = atomcolors(resz_obs[]; colors = aquacolors)
    @test length(acolors) == 1960
    acolors = atomcolors(chn_obs[]; colors = aquacolors)
    @test length(acolors) == 2203
    acolors_obs = atomcolors(chn_obs; colors = aquacolors)
    @test length(acolors_obs[]) == 2203
    acolors = atomcolors(resz_obs; colors = aquacolors)
    @test acolors[][1] == RGB{Float64}(0.472,0.211,0.499)
    acolors = atomcolors(resz_obs[]; colors = aquacolors)
    @test acolors[1] == RGB{Float64}(0.472,0.211,0.499)
    acolors = atomcolors(chn_obs[]; colors = aquacolors)
    @test acolors[1] == RGB{Float64}(0.472,0.211,0.499)

    rcolors = rescolors(resz_obs)
    @test rcolors[][1] == :orange
    rcolors = rescolors(resz_obs[])
    @test rcolors[1] == :orange
    # rcolors = rescolors(chn_obs[])    # 
    # @test rcolors[1] == :orange

    # MIToS
    filename = downloadpfam("PF00062"; filename = "$(dir)/PF00062.stockholm.gz")
    msa1 = MIToS.MSA.read("$(dir)/PF00062.stockholm.gz",Stockholm, generatemapping=true, useidcoordinates=true)
    plotdata = plottingdata(msa1)
    msamatrix = plotdata["matrix"]
    xlabel = plotdata["xlabels"]
    ylabel = plotdata["ylabels"]
    @test typeof(msamatrix) <: AbstractArray{String}
    @test typeof(xlabel) <: AbstractArray{String}
    @test typeof(ylabel) <: AbstractArray{String}

    # pdbfile = MIToS.PDB.downloadpdb("2vb1"; filename = "$(dir)/2vb1.pdb")     # download problems with ".gz"
    res_2vb1 = MIToS.PDB.read("$(dir)/2vb1.pdb", MIToS.PDB.PDBFile)
    chn = MIToS.PDB.@residues res_2vb1 model "1" chain "A" group "ATOM" residue All
    chn_obs = Observable(chn);
    reszizes = [size(chn[i].atoms,1) for i in 1:size(chn,1)] 
    @test sum(reszizes) == 2657
    @test length(res_2vb1) == 312

    acolors = atomcolors(res_2vb1; colors = aquacolors)
    @test length(acolors) == 2203
    acolors = atomcolors(chn_obs[]; colors = aquacolors)
    @test length(acolors) == 1960
    acolors_obs = atomcolors(chn_obs; colors = aquacolors)
    @test length(acolors_obs[]) == 1960
    acolors = atomcolors(res_2vb1; colors = aquacolors)
    @test acolors[1] == RGB{Float64}(0.472,0.211,0.499)
    acolors = atomcolors(chn_obs[]; colors = aquacolors)
    @test acolors[1] == RGB{Float64}(0.472,0.211,0.499)
    acolors = atomcolors(chn_obs; colors = aquacolors)
    @test acolors[][1] == RGB{Float64}(0.472,0.211,0.499)

    rcolors = rescolors(chn)
    @test rcolors[1] == :orange
    # rcolors = rescolors(res_2vb1)
    # @test rcolors[][1] == :orange
    # @test length(rescolors(res_2vb1)) == 1960

    # Delete temporary directory
    rm(dir, recursive=true, force=true)
end
