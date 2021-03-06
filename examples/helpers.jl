function loadNeuralNet()
    path(s) = normpath("$(@__DIR__)/"*s)
    @load path("../models/agz_128_base.bson") bn
    @load path("../models/agz_128_value.bson") value
    @load path("../models/agz_128_policy.bson") policy
    @load path("../models/weights/agz_128_base.bson") bn_weights
    @load path("../models/weights/agz_128_value.bson") val_weights
    @load path("../models/weights/agz_128_policy.bson") pol_weights
    Flux.loadparams!(bn,bn_weights)
    Flux.loadparams!(value, val_weights)
    Flux.loadparams!(policy, pol_weights)
    # bn = mapleaves(cu, bn)
    # value = mapleaves(cu, value)
    # policy = mapleaves(cu, policy)
    NeuralNet(base_net = bn, value = value, policy = policy)
end



function playMove()
    move = AlphaGo.suggest_move(agz)
    println(go.to_kgs(move))
    play_move!(agz, move)
    return move
end

function playMove(x)
    move = actionToString(x)
    @show move
    play_move!(agz, go.from_kgs(move))
    return move
end

function actionToString(a)
    a["y"] == -1 && a["x"] == -1 && return "pass"
    t = (a["y"], a["x"]) .+ 1
    go.to_kgs(t)
end

function stringToAction(s, c)
    s == "pass" && return Dict("x"=>-1,"y"=>-1,"c"=>c)
    (y, x) = go.from_kgs(s) .- 1
    Dict("x"=>x,"y"=>y,"c"=>c)
end

function isIllegalMove(x)
    AlphaGo.get_position(agz) == nothing && return true
    !AlphaGo.go.is_move_legal(AlphaGo.get_position(agz), go.from_kgs(actionToString(x)))
end

# for rendering board
function updateBoard(move)
    env = Dict()
    pos = AlphaGo.get_position(agz)
    board = []
    if ( pos.board == nothing )
        board = map(i -> map(j-> [], 1:9), 1:9)
    else
        for i=1:go.N
            row = []
            for j=1:go.N
                cont = []
                if pos.board[j, i] == 1 || pos.board[j, i] == -1
                    push!(cont, Dict("x"=>(i - 1),"y"=>(j - 1),"c"=>pos.board[j, i], "type"=>"NORMAL"))
                end
                push!(row, cont)
            end
            push!(board, row)
        end
    end
    env["state"] = Dict("objects"=>board)
    env["action"] = move
    update!(gw, env)
end
