#### Problem generation ####

m=[2,3,4,5,6]; # Problem size
I=10.*m; #number of costumers
J=m+1; # number of service facilities
K=3(m+1) #number of potential locations for defence facilities

function Ecualidian_distanse(x1::Float64,x2::Float64,y1::Float64,y2::Float64)
    dist=((x1-x2)^2+(y1-y2)^2)^(1/2)
    return dist
end

# customer locations
customer_location=zeros(I[1],2)
for i=1:I[1]
    customer_location[i,1]=1000*rand()
    customer_location[i,2]=1000*rand()
end

#service locations
service_location=zeros(J[1],2)
for j=1:J[1]
    service_location[j,1]=1000*rand()
    service_location[j,2]=1000*rand()
end

#potential defence positions
pdef_location=zeros(K[1],2)
for k=1:K[1]
    pdef_location[k,1]=1000*rand()
    pdef_location[k,2]=1000*rand()
end

distance_cus_ser=zeros(I[1],J[1])# distance between customer i and service facility j

for i=1:I[1]
    for j=1:J[1]
        dist=Ecualidian_distanse(customer_location[i,1],service_location[j,1],customer_location[i,2],service_location[j,2])
        distance_cus_ser[i,j]=dist
    end
end

distance_ser_pdef=zeros(J[1],K[1]) # distance between service facility j and potential position for defence facilities
for j=1:J[1]
    for k=1:K[1]
        dist=Ecualidian_distanse(service_location[j,1],pdef_location[k,1],service_location[j,2],pdef_location[k,2])
        distance_ser_pdef[j,k]=dist
    end
end

customer_demand=zeros(1,I[1]) # defining customer demand
for i=1:I[1]
    customer_demand[i]=rand(collect(5:5:100))
end

def_pos_cost=zeros(1,K[1]) # cost of stablishing a defence facility at position k
for k=1:K[1]
    def_pos_cost[k]=rand(collect(1000:1000:20000))
end

attacker_buddet=2; # attacker budget ### Must change based on  the paper
 r=60  #range of defence facilities

 #service facilities capacity
 ser_cap=zeros(1,J[1]);
 q_p_vec=zeros(1,J[1]);
for j=1:J[1]
    q_p_vec[j]=rand([1,m[1]+1])
end
su=(1+rand())*sum(customer_demand)
for j=1:J[1]
    ser_cap[j]=(su*q_p_vec[j])/sum(q_p_vec)
end
for j=1:J[1]
    a=rem(ser_cap[j],20)
    ser_cap[j]=ser_cap[j]-a
end

#defining probablity of defence
prob_matrix=zeros(size(distance_ser_pdef))
for j=1:J[1]
    p_l=0
    p_u=0
    for k=1:K[1]
        if 0<distance_ser_pdef[j,k]<=r
            p_u=0.95
        else
            p_u=0.15
        end
        if distance_ser_pdef[j,k]>r
            p_l=0.15
        else
            p_l=0.95
        end
        prob_matrix[j,k]=p_l+(((p_u-p_l)*(r-distance_ser_pdef[j,k]))/r)
    end
end

CS=2 #unit shipment cost of demand per unit distance
CO=500 # unit outsourcing cost of demand (independent of distance)
