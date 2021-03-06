export FourRooms

mutable struct FourRooms <: AbstractGridWorld
    world::GridWorldBase{Tuple{Empty,Wall,Goal}}
    agent_pos::CartesianIndex{2}
    agent::Agent
    goal_reward::Float64
    reward::Float64
end

function FourRooms(;n=9, agent_start_pos=CartesianIndex(2,2), agent_start_dir=RIGHT, goal_pos=CartesianIndex(n-1, n-1))
    objects = (EMPTY, WALL, GOAL)
    world = GridWorldBase(objects, n, n)

    world[WALL, [1,n], 1:n] .= true
    world[WALL, 1:n, [1,n]] .= true
    world[WALL, ceil(Int,n/2), vcat(2:ceil(Int,n/4)-1,ceil(Int,n/4)+1:ceil(Int,n/2)-1,ceil(Int,n/2):ceil(Int,3*n/4)-1,ceil(Int,3*n/4)+1:n)] .= true
    world[WALL, vcat(2:ceil(Int,n/4)-1,ceil(Int,n/4)+1:ceil(Int,n/2)-1,ceil(Int,n/2):ceil(Int,3*n/4)-1,ceil(Int,3*n/4)+1:n), ceil(Int,n/2)] .= true
    world[EMPTY, :, :] .= .!world[WALL, :, :]
    world[GOAL, goal_pos] = true
    world[EMPTY, goal_pos] = false

    goal_reward = 1.0
    reward = 0.0

    env = FourRooms(world,agent_start_pos,Agent(dir=RIGHT), goal_reward, reward)

    reset!(env, agent_start_pos = agent_start_pos, agent_start_dir = agent_start_dir, goal_pos = goal_pos)

    return env
end

function (env::FourRooms)(::MoveForward)
    dir = get_dir(env.agent)
    dest = dir(env.agent_pos)
    env.reward = 0.0
    if !env.world[WALL, dest]
        env.agent_pos = dest
        if env.world[GOAL, env.agent_pos]
            env.reward = env.goal_reward
        end
    end
    env
end

RLBase.get_terminal(env::FourRooms) = env.world[GOAL, env.agent_pos]

function RLBase.reset!(env::FourRooms; agent_start_pos = CartesianIndex(2, 2), agent_start_dir = RIGHT, goal_pos = CartesianIndex(size(env.world[end]) - 1, size(env.world)[end] - 1))
    n = size(env.world)[end]
    env.reward = 0.0
    env.agent_pos = agent_start_pos
    agent = get_agent(env)
    set_dir!(agent, agent_start_dir)

    env.world[GOAL, :, :] .= false
    env.world[GOAL, goal_pos] = true
    env.world[EMPTY, :, :] .= .!env.world[WALL, :, :]
    env.world[EMPTY, goal_pos] = false
    return env
end
