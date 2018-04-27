using JuMP,Cbs

################ Index ###################
I=20; # set of customer (i<I)
J=3; # set of service facilities (j<J)
K=9; # set of possible locations for establishing defence
################## Parameters ########################

# customer demand
a=[35.0 95.0 85.0 30.0 10.0 75.0 10.0 95.0 40.0 50.0 35.0 100.0 10.0 65.0 15.0 55.0 35.0 55.0 60.0 55.0];

#distance between service facility and customer
d=[706.834 858.766 554.051 708.77 83.7825 709.958 685.75 450.249 116.064;
   626.877 572.052 275602 414.002 378.456 470.196 460.205 171.771 308.9;
   878.081 963.325 664.683 745.038 212.353 843.988 825.287 488.992 84.9972]

# the cost of stablishing a defence facilitiy in location k
c=[18000.0 19000.0 19000.0 1000.0 5000.0 17000.0 5000.0 2000.0 6000.0]

r=60; #coverage range of each defence facility

#distance between facility j and defence k
f=[706.834 858.766 554.051 708.77 83.7825 709.958 685.75 450.249 116.064;
   626.877 572.052 275.602 414.002 378.456 470.196 460.205 171.771 308.9;
   878.081 963.325 664.683 745.038 212.353 843.988 825.287 488.992 84.9972]

#unit shipment cost of demand per unit distance
CS=2
 # unit outsourcing cost of demand (independent of distance)
CO=500
Kp=Vector(); #set of defence facalities that are in range of service facilities



###################### Model ###################################

m1=Model(solver=CbcSolver())

@variable(m1,X[1:K],Bin) #if decided to establish a defence facility in site k X[k]=1...
@variable(m1,Y[1:J,1:K],Bin)

@objective(m1,Min,sum(c[k]*X[k] for k=1:K))


for j=1:J
    @constraint(m1,sum(Y[j,k=1:K])>=1)  ##2
end

for k=1:K
    @constraint(m1,sum(Y[j=1:J,k])<=10000*X[k]) ##3
end

for j=1:J
    for k=1:K
        @constraint(m1,Y[j,k]*f[j,k]<=r) ##4
    end
end

##5

########## level 2 model ##########


########## level 3 model ##########
m3=mode(solver=CbcSolver())
@variable(m3,U[1:I,1:J])
@objective(m3,Min,sum(sum(a[i]*d[i,j]*U[i,j] for i=1:I, j=1:J)))
