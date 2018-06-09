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

function Sort(population) # sort population based of their fitness
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

function HammingDistance(a::Array{Int32},b::Array{Int32})
	distance=countnz(a-b);
end

function FrogLeap(best_sol::Array{Int64},worst_sol::Array{Int64},smax::Int64)
	new_sol=deepcopy(worst_sol)
	p1=rand(2:length(best_sol)-smax)
	p2=p1+min(HammingDistance(best_sol,worst_sol),smax)

	@show block=best_sol[p1:p2];
	@show new_sol[p1:p2]=block
	return new_sol
end

function SelectionProb(n)
    prob_vector=[];
    for i=1:n
        p=2*(n+1-i)/(n*(n+1))
        push!(prob_vector,p)
    end
    return prob_vector
end

function CreatePop(m,n,K)
    population=[];
    for i=1:n*m
        seq=zeros(K);
        for j=1:K
            if rand()<0.5
               seq[j]=1
           else
               seq[j]=0
            end
        end
        sol=solution(seq,0)
        push!(population,sol)
    end
    return population
end
