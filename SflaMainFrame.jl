
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
