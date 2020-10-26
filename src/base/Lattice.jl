# -- PRIVATE METHODS ---------------------------------------------------------------------------------------------------- #
# ----------------------------------------------------------------------------------------------------------------------- #

# -- PUBLIC METHODS ----------------------------------------------------------------------------------------------------- #
function ternary_price_tree(initialPrice::Float64, treeHeight::Int64, deltaFunction::Function)::PSResult

    # TODO: check - are the args legit?

    # initialize -
    number_of_nodes = Int((3^(treeHeight+1) - 1)/2)
    priceTree::Array{Float64,1}(undef,number_of_nodes)

    # set the current price -
    priceTree[1] = initialPrice

    # main loop -
    for node_index = 1:number_of_nodes
        
        # for this node, what are the delta values?
        (u,m,d) = deltaFunction(treeHeight)

        # TODO: check, is u,m,d values ...

        # what is the current price -
        basePrice = priceTree[node_index]

        # build my kid's prices -
        upValue = u*basePrice
        midValue = m*basePrice
        downValue = d*basePrice

        # set my kids -
        leftIndex = 3*node_index - 1
        midIndex = 3*node_index
        rightIndex = 3*node_index + 1

        # set the prices -
        priceTree[leftIndex] = upValue
        priceTree[midIndex] = midValue
        priceTree[rightIndex] = downValue
    end

    # return -
    return PSResult{Array{Float64,1}}(priceTree)
end
# ----------------------------------------------------------------------------------------------------------------------- #