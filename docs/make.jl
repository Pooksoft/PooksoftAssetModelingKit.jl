using Documenter
using PooksoftAssetModelingKit

makedocs(sitename="PooksoftAssetModelingKit.jl",

    pages = [
        "index.md",
        "Quick Start" => "quick.md",
        "Stochastic models" => [
            "stochastic.md"
        ],
        
        "Lattice models" => [
            "lattice.md"
        ]
    ]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
# deploydocs(
#     repo = "github.com/Pooksoft/PooksoftAssetModelingKit.jl",
#     devurl = "stable",
# )
