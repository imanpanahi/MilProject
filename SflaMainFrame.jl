type solution
    seq::Array{Int64}
    fitness::Float64
end

function TwoPointCrossOver(best::Array{Int64,1},sol::Array{Int64,1})
        p_1=rand(2:length(best)-1)
        p_2=rand(2:length(best)-1)

        if p_1==p_2
            p_2=p_1+1
        end
        int_best=best[p_1:p_2]

        new_sol=deepcopy(sol)
        new_sol[p_1:p_2]=int_best
        return new_sol
end

function SortPop(population) # sort population based of their fitness
    fits=zeros(length(population))
    for i=1:length(population)
        fits[i]=population[i].fitness
    end
    key=sortperm(fits)
    s_population=population[key];
end

function Partition(s_population,m,n) # partition population into m memplex
    p_population=[]
    memplex=[];
    s=1
    c=1
    for j=1:m
        s=c
        while s<=m*n
            push!(memplex,s_population[s])
            s=s+m
        end
        push!(p_population,memplex)
        memplex=[];
        c=c+1
    end
    return p_population
end
