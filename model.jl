using JuMP,Cbc,Gadfly

function Ecualidian_distanse(x1::Float64,x2::Float64,y1::Float64,y2::Float64)
    dist=((x1-x2)^2+(y1-y2)^2)^(1/2)
    return dist
end
################ Index ###################
I=20; # set of customer (i<I)
J=3; # set of service facilities (j<J)
K=9; # set of possible locations for establishing defence
################## Parameters ########################
#costumer location
costumer_location=[ 162.312   286.268
                    197.187   842.411
                    868.178   814.67
                    462.966   680.692
                    598.665   684.046
                    27.3373  440.171
                    96.5991  718.215
                    142.16    745.368
                    454.988   731.582
                    608.22    288.027
                    117.664   791.96
                    806.964   101.707
                    220.986   400.692
                    682.917    18.6734
                    999.23    949.455
                    209.858   932.908
                    727.525   181.241
                    117.496   314.118
                    613.169   682.684
                    804.046   134.233];
#potential defence facilities location
pdef_location=[ 882.754  846.182
                843.319  215.314
                610.862  412.394
                460.733  110.689
                177.43   845.614
                819.911  452.415
                813.314  496.604
                336.915  339.528
                96.554  682.244];
#service_location
service_location= [180.963   761.906;353.318   510.514;15.5935  708.127];

# customer demand
a=[35.0 95.0 85.0 30.0 10.0 75.0 10.0 95.0 40.0 50.0 35.0 100.0 10.0 65.0 15.0 55.0 35.0 55.0 60.0 55.0];

#distance between customer and service facility
d=[476.003 294.567 446.644;
   82.1233 366.787 225.85;
   689.238 597.989 859.216;
   293.464 202.443 448.212;
   424.897 300.513 583.568;
   356.531 333.484 268.214;
   95.0059 330.219 81.6312;
   42.1797 315.823 131.932;
   275.698 243.327 440.02;
   638.052 338.342 726.423;
   70.071 367.076 132.085;
   909.802 610.669 997.001;
   363.425 171.967 369.734;
   896.857 592.066 959.514;
   839.485 780.942 1012.81;
   173.426 446.092 297.094;
   797.435 498.448 885.695;
   452.263 306.893 406.973;
   439.407 311.713 598.116;
   884.425 587.149 975.199];
# the cost of stablishing a defence facilitiy in location k
c=[18000.0,19000.0,19000.0,1000.0,5000.0,17000.0,5000.0,2000.0,6000.0]

r=500; #coverage range of each defence facility

#distance between facility j and defence k
f=[706.834 858.766 554.051 708.77 83.7825 709.958 685.75 450.249 116.064;
   626.877 572.052 275.602 414.002 378.456 470.196 460.205 171.771 308.9;
   878.081 963.325 664.683 745.038 212.353 843.988 825.287 488.992 84.9972]

#probability of service facility j defenced buy defence facility located in k th position
p=[0.15  0.15  0.15  0.15  0.15  0.15  0.15  0.15  0.15
 0.15  0.15  0.15  0.15  0.15  0.15  0.15  0.15  0.15
 0.15  0.15  0.15  0.15  0.15  0.15  0.15  0.15  0.15]
# service facilities capacity
q=[220 700 700];

#unit shipment cost of demand per unit distance
CS=2

 # unit outsourcing cost of demand (independent of distance)
CO=500

#Attacekr Budget
B=2

###################### Model ###################################

m1=Model(solver=CbcSolver())

@variable(m1,X[1:K],Bin) #if decided to establish a defence facility in site k X[k]=1...
@variable(m1,Y[1:J,1:K],Bin) # if jth facility covered by kth defence

@objective(m1,Min,sum(c[k]*X[k] for k=1:K))


for j=1:J
    @constraint(m1,sum(Y[j,k=1:K])>=1)  ##2
end

for k=1:K
    @constraint(m1,sum(Y[j=1:J,k])<=1000*X[k]) ##3
end

for j=1:J
    for k=1:K
        @constraint(m1,Y[j,k]*f[j,k]<=r) ##4
    end
end

for j=1:J
   for k=1:K
      if Ecualidian_distanse(service_location[j,1],pdef_location[k,1],service_location[j,2],pdef_location[k,2])<=r
         @constraint(m1,Y[j,k]==1)
      end
   end
end

solve(m1)
getobjectivevalue(m1)

########## level 2 model ##########
m2=Model(solver=CbcSolver());

@variable(m2,S[1:J],Bin)
@constraint(m2,sum(S[j] for j=1:J)<=B)

########## level 3 model ##########
m3=Model(solver=CbcSolver())

@variable(m3,U[1:I,1:J],Bin) # if customer i allocated to service j
#@variable(m3,T[1:J],Bin) ## this variable is equal to S[j] variable in M2 model
#@variable(m3,V[1:J,1:K],Bin) ## this vaiable is equal to Y[i,j] variable in M1 model
T=[1,0,1];
V=[1 0 0 1 0 1 0 1 1;0 0 0 0 0 1 0 1 1;1 0 0 1 1 0 0 0 0;]


@objective(m3,Min,CS*(sum(sum(a[i]*d[i,j]*U[i,j] for i=1:I) for j=1:J))+(sum(a[i] for i=1:I)*(1-(sum(sum(U[i,j] for i=1:I) for j=1:J)))))

for i=1:I
    @constraint(m3,sum(U[i,j] for j=1:J)<=1)
end


for j=1:J
    c=prod(1-p[j,:].*V[j,:])
    @constraint(m3,sum(a[i]*U[i,j] for i=1:I)<=q[j]*(1-T[j])*prod(1-p[1,:].*V[1,:])+q[j]*(1-prod(1-p[1,:].*V[1,:])))
end
@time solve(m3)
getobjectivevalue(m3)




plot(
      layer(x=costumer_location[:,1], y=costumer_location[:,2],Geom.point,color=[colorant"black"],shape=[Shape.diamond]),
      layer(x=service_location[:,1],y=service_location[:,2],Geom.point,color=[colorant"orange"],shape=[Shape.circle]),
      layer(x=pdef_location[:,1],y=pdef_location[:,2],Geom.point,color=[colorant"purple"],shape=[Shape.xcross]),
      Guide.manual_color_key("locations", ["costumer locations", "service locations","defence faciity locations"],
                           ["black", "orange","purple"]),
      Theme(background_color="white", point_size=6pt)
       )
