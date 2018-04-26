using JuMP,Cbs



################ Index ###################



I=20; # set of customer (i<I)

J=3; # set of service facilities (j<J)

K=10; # set of possible locations for establishing defence



################## Parameters ########################



c=[20,30,24,10,14,14,42,9,22,16] # the cost of stablishing a defence facilitiy in location k

r=30; #coverage range of each defence facility

f=rand(Vector(10:200),(J,K)) #distance between facility j and defence k

Kp=Vector(); #set of defence facalities that are in range of service facilities



###################### Model ###################################

m1=Model(solver=CbcSolver())



@variable(m1,X[1:K],Bin) #if decided to establish a defence facility in site k X[k]=1...

@variable(m1,Y[1:J,1:K],Bin)



@objective(m1,Min,sum(c[k]*X[k] for k=1:K))



for j=1:J

    @constraint(m1,sum(Y[j,k=1:K])>=1)

end



for k=1:K

    @constraint(m1,sum(Y[j=1:J,k])<=10000*X[k])

end



for j=1:J

    for k=1:K

        @constraint(m1,Y[j,k]*f[j,k]<=r)

    end

end



print(m1)

status=solve(m1)
 
