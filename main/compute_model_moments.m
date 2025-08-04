function model_moments=compute_model_moments(S,numb,asset_dist_simul,parameters,agrid)
% distribution

model_moments=[];

pwd
load ./external_parameters/Emp_Age_new.mat
load ./external_parameters/DEmp_new
%load ./external_parameters/Emp_Dcrime_new
load ./external_parameters/Emp_Dchurch_new
load ./external_parameters/Emp_Educ_new
load ./external_parameters/UN_Educ_new
%load ./external_parameters/UN_Dcrime_new
load ./external_parameters/UN_Dchurch_new
load ./external_parameters/UN_Age_new
load ./external_parameters/rel_UE_new %this is the one only for the religious groups. Ordered as: catholic pentecostal protestant other
load ./external_parameters/rel_UE_all_new % this includes non religious: ordering as: catholic pentecostal protestant other no religion
load ./external_parameters/Emp_Age_new.mat

q_bar   =1; %utility shock in case of an expense shock
theta1  =parameters(1);  
%theta2  =parameters(2);
psi     =parameters(2);  
Vheaven =parameters(3);
zetta   =parameters(4); %weight on donations
zetta_h =parameters(5); %weight on pray
alpha   =  parameters(16);  % elasticity
s_bar = (zetta*0.012^theta1+(1-zetta)*0.017^theta1)^(1/theta1);
A_high = parameters(17);  A_low = 1 ; church_prod = [A_high A_low]; Ach = church_prod;

phi_0=[parameters(6),parameters(8),parameters(10),parameters(12),parameters(14)];
%phi_exp=[parameters(9),parameters(13),parameters(17),parameters(21)];
phi_2=[parameters(7),parameters(9),parameters(11),parameters(13),parameters(15)];
%phi_4=[parameters(11),parameters(15),parameters(19),parameters(23)];

[ca cb cc cd]=ndgrid(asset_dist_simul,Emp_Age_new,Emp_Educ_new,Emp_Dchurch_new);
combs1 = [ca(:), cb(:), cc(:), cd(:)];

Dist_emp=prod(combs1,2);
%Dist_emp=Dist_emp*DEmp(2); %(this does not sum up to 1)

[ca cb cc cd]=ndgrid(asset_dist_simul,UN_Age_new,UN_Educ_new,UN_Dchurch_new);
combs2 = [ca(:), cb(:), cc(:), cd(:)];

Dist_un=prod(combs2,2);
%Dist_un=Dist_un*DEmp(1); %(this does not sum up to 1)

%Distr=[Dist_un; Dist_emp]; % distribution, before religion
%====================%
%Distribution
%====================%
% Order: religion - Emloyment- Church- Education - Age - Assets
% for example (1,1) and (2,1) we move along the asset grid while all other
% properties are the same
Distr=[];
for rel=1:5 %including nonreligious too 
    Distr=[Distr; rel_UE_all_new(rel,1)*Dist_un; rel_UE_all_new(rel,2)*Dist_emp]; %creating the distribution after religion. rel_UE has distribution by religion for Employed and Unemployed
end

%====================%
%vector donations:
%====================%
Vec_donation=[];

for rel=1:5
    Vec_donatios_un=[]; Vec_donatios_e=[];
    for az=1:2*3
        Vec_donatios_un=[Vec_donatios_un; S{rel,az}. pol_o(1:2:numb,2)./S{rel,az}. pol_o(1:2:numb,9); S{rel,az}. pol_m(1:2:numb,2)./S{rel,az}. pol_m(1:2:numb,9); S{rel,az}. pol_y(1:2:numb,2)./S{rel,az}. pol_y(1:2:numb,9)];
        Vec_donatios_e =[Vec_donatios_e ; S{rel,az}. pol_o(2:2:numb,2)./S{rel,az}. pol_o(2:2:numb,9); S{rel,az}. pol_m(2:2:numb,2)./S{rel,az}. pol_m(2:2:numb,9); S{rel,az}. pol_y(2:2:numb,2)./S{rel,az}. pol_y(2:2:numb,9)];
    end
    Vec_donation=[Vec_donation; Vec_donatios_un;Vec_donatios_e];
    
end

Vec_asset=[];

for rel=1:5
    Vec_asset_un=[]; Vec_asset_e=[];
    for az=1:2*3
        Vec_asset_un=[Vec_asset_un; S{rel,az}. pol_o(1:2:numb,1); S{rel,az}. pol_m(1:2:numb,1); S{rel,az}. pol_y(1:2:numb,1)];
        Vec_asset_e =[Vec_asset_e ; S{rel,az}. pol_o(2:2:numb,1); S{rel,az}. pol_m(2:2:numb,1); S{rel,az}. pol_y(2:2:numb,1)];
    end
    Vec_asset=[Vec_asset; Vec_asset_un;Vec_asset_e];
end
%====================%
%Voluntary work
%====================%
%vector vwork:
Vec_vwork=[];
for rel=1:5
    Vec_vwork_un=[]; Vec_vwork_e=[];
    
    for az=1:2*3
        Vec_vwork_un=[Vec_vwork_un; S{rel,az}. pol_o(1:2:numb,5); S{rel,az}. pol_m(1:2:numb,5); S{rel,az}. pol_y(1:2:numb,5)];
        Vec_vwork_e =[Vec_vwork_e ; S{rel,az}. pol_o(2:2:numb,5); S{rel,az}. pol_m(2:2:numb,5); S{rel,az}. pol_y(2:2:numb,5)];
    end
    Vec_vwork=[Vec_vwork;Vec_vwork_un;Vec_vwork_e];
end
%====================%
%Pray
%====================%
%vector pray:
Vec_pray=[];
for rel=1:5
Vec_pray_un=[]; Vec_pray_e=[];

for az=1:2*3
    Vec_pray_un=[Vec_pray_un; S{rel,az}. pol_o(1:2:numb,4); S{rel,az}. pol_m(1:2:numb,4); S{rel,az}. pol_y(1:2:numb,4)];
    Vec_pray_e =[Vec_pray_e ; S{rel,az}. pol_o(2:2:numb,4); S{rel,az}. pol_m(2:2:numb,4); S{rel,az}. pol_y(2:2:numb,4)];
end
Vec_pray=[Vec_pray;Vec_pray_un;Vec_pray_e];
end

%====================%
%Transitions
%====================%
%vector transition: becoming employed
Vec_trans=[];
for rel=1:5
Vec_trans_un=[]; Vec_trans_e=[];

for az=1:2*3
    Vec_trans_un=[Vec_trans_un; S{rel,az}. trans_o(1:2:numb,2); S{rel,az}. trans_m(1:2:numb,2); S{rel,az}. trans_y(1:2:numb,2)];
    Vec_trans_e =[Vec_trans_e ; S{rel,az}. trans_o(2:2:numb,2); S{rel,az}. trans_m(2:2:numb,2); S{rel,az}. trans_y(2:2:numb,2)];
end
Vec_trans=[Vec_trans;Vec_trans_un;Vec_trans_e];
end

%====================%
%Working time
%====================%
%vector work:
Vec_work=[];
for rel=1:5
Vec_work_un=[]; Vec_work_e=[];

for az=1:2*3
    Vec_work_un=[Vec_work_un; 1-S{rel,az}. pol_o(1:2:numb,3)-S{rel,az}. pol_o(1:2:numb,4)-S{rel,az}. pol_o(1:2:numb,5); 1-S{rel,az}. pol_m(1:2:numb,3)-S{rel,az}. pol_m(1:2:numb,4)-S{rel,az}. pol_m(1:2:numb,5); 1-S{rel,az}. pol_y(1:2:numb,3)-S{rel,az}. pol_y(1:2:numb,4)-S{rel,az}. pol_y(1:2:numb,5)];
    Vec_work_e =[Vec_work_e ; 1-S{rel,az}. pol_o(2:2:numb,3)-S{rel,az}. pol_o(2:2:numb,4)-S{rel,az}. pol_o(2:2:numb,5); 1-S{rel,az}. pol_m(2:2:numb,3)-S{rel,az}. pol_m(2:2:numb,4)-S{rel,az}. pol_m(2:2:numb,5); 1- S{rel,az}. pol_y(2:2:numb,3)-S{rel,az}. pol_y(2:2:numb,4)-S{rel,az}. pol_y(2:2:numb,5)];
end
Vec_work=[Vec_work;Vec_work_un;Vec_work_e];
end


%====================%
%Moment 2:avg donation
%====================%
Avg_donation=Distr'*Vec_donation; %mean
model_moments=[model_moments;Avg_donation];
%====================%
%Moment 3:
%cor don w income
%====================%
Avg_asset=Distr'*Vec_asset; %mean
var_asset=Distr'*(Vec_asset-Avg_asset).^2; %variance
sd_asset=var_asset^(0.5);
var_donation=Distr'*(Vec_donation-Avg_donation).^2; %variance
sd_donation=var_donation^(0.5);

corr_ad=(sd_asset*sd_donation)^(-1)* Distr'*((Vec_donation - Avg_donation).*( Vec_asset-Avg_asset));
%model_moments=[model_moments;corr_ad];
%====================%
%Moment 4-8:
%avg don per religion
%====================%
size_D=size(Distr,1)/5; %bcs we have 5 religions (including nonreligous too)
dist_rel=[sum(Distr(1:size_D)); sum(Distr(size_D+1:2*size_D));sum(Distr(1+2*size_D:3*size_D));sum(Distr(3*size_D+1:4*size_D));sum(Distr(4*size_D+1:5*size_D))];


for rel=1:5 
    b_don(rel,1)=dist_rel(rel)^(-1)*Distr((rel-1)*size_D+1:rel*size_D)'*Vec_donation((rel-1)*size_D+1:rel*size_D);
end
model_moments=[model_moments; b_don];
%====================%
%Moment 9-12:
%avg don per age
%====================%
ag=agrid+1;
Vec_donation_o=[];Vec_donation_m=[];Vec_donation_y=[]; dis_o=[];dis_m=[];dis_y=[];
%creating distributions for ages/ old mid young
for as=1:3:size(Distr,1)/(3*ag)
    Vec_donation_o=[Vec_donation_o; Vec_donation((as-1)*(ag)+1: as*ag)];
    dis_o=[dis_o; Distr((as-1)*ag+1: as*ag)] ;
    
    Vec_donation_m=[Vec_donation_m; Vec_donation((as)*(ag)+1: (as+1)*ag)];
    dis_m=[dis_m; Distr((as)*ag+1: (as+1)*ag)] ;
    
    Vec_donation_y=[Vec_donation_y; Vec_donation((as+1)*(ag)+1: (as+2)*ag)];
    dis_y=[dis_y; Distr((as+1)*ag +1: (as+2)*ag )] ;
end
don_o=(sum(dis_o))^(-1) * dis_o' *Vec_donation_o;
don_m=(sum(dis_m))^(-1) * dis_m' *Vec_donation_m;
don_y=(sum(dis_y))^(-1) * dis_y' *Vec_donation_y;

model_moments=[model_moments; don_y;don_m;don_o];

%====================%
%Moment 13-14 [UPDATE 10-11]:
%avg don per church
%====================%
Vec_donation_h=[];Vec_donation_l=[];dis_h=[];dis_l=[];

%creating distributions for church levels 
for as=1:2:size(Distr,1)/(3*ag*3*2) %3 education level/asset grid/3 age groups/ 2 church 
    Vec_donation_h=[Vec_donation_h; Vec_donation((as-1)*(3*ag*3)+1: as*3*ag*3)];
    dis_h=[dis_h; Distr((as-1)*(3*ag*3)+1: as*3*ag*3)] ;
    
    Vec_donation_l=[Vec_donation_l; Vec_donation((as)*(3*ag*3)+1: (as+1)*3*ag*3)];
    dis_l=[dis_l; Distr((as)*(3*ag*3)+1: (as+1)*3*ag*3)] ;
    
    
end
don_h=(sum(dis_h))^(-1) * dis_h' *Vec_donation_h;
don_l=(sum(dis_l))^(-1) * dis_l' *Vec_donation_l;
model_moments=[model_moments; don_l;don_h];

%====================%
%Moment 13-18:
%reg donation on ---
%====================%
%R explanatory , reg_don dependent variable
% R=[];reg_don=[]; %R the matrix for variable: pen prot other mid old high_crim
% for i=1:size(Distr,1)
%     num_obs=round(observation*Distr(i));
%     if num_obs>0
%         reg_don=[reg_don; Vec_donation(i)* ones(num_obs,1)]; %creating the dependent variable
%         
%         r_k=[zeros(1,6) 1]; %constant is the final term
%         %if i<=size_D %catholic  
%         if i>size_D && i<=2*size_D %pentecostal
%             r_k(1)=1;
%         elseif i>2*size_D && i<=3*size_D %protestant
%             r_k(2)=1;
%         elseif i>3*size_D && i<=4*size_D %other religion
%             r_k(3)=1;
%         end
%         
%         z1=rem(i,ag*3); %age group
%         if z1>ag && z1<=2*ag %mid age
%             r_k(4)=1;
%         elseif z1<=ag %old
%             r_k(5)=1;
%  
%         end
%         
%         z2=rem(i,ag*3*3*2); %highcrime=1
%         if z2<=ag*3*3
%             r_k(6)=1;
%         end
%         
%         R=[R; ones(num_obs,1)*r_k];
%     end      
% end
%  reg_coeff=regress(reg_don,R); %careful to drop the final estimated coefficient, cause it's the constant
%  model_moments=[model_moments; reg_coeff(1:6)];

%====================%
%Moment 19:avg time
%====================%
Avg_time=Distr'*Vec_vwork; %mean
model_moments=[model_moments;Avg_time];
%====================%
%Moment 20:
%cor time w income
%====================%
Avg_asset=Distr'*Vec_asset; %mean
var_asset=Distr'*(Vec_asset-Avg_asset).^2; %variance
sd_asset=var_asset^(0.5);
var_time=Distr'*(Vec_vwork-Avg_time).^2; %variance
sd_time=var_time^(0.5);

%corr_ad=(sd_asset*sd_time)^(-1)* Distr'*((Vec_vwork - Avg_time).*( Vec_asset-Avg_asset));
%model_moments=[model_moments;corr_ad];
%====================%
%Moment 21-24:
%avg time per religion
%====================%
% standardize time
Vec_vwork_std = (Vec_vwork - Avg_time)/sd_time;
size_D=size(Distr,1)/5; %bcs we have 4 religions
%dist_rel=[sum(Distr(1:size_D)); sum(Distr(size_D+1:2*size_D));sum(Distr(1+2*size_D:3*size_D));sum(Distr(3*size_D+1:4*size_D));sum(Distr(4*size_D+1:5*size_D))];
dist_rel=[sum(Distr(1:size_D)); sum(Distr(size_D+1:2*size_D));sum(Distr(1+2*size_D:3*size_D));sum(Distr(3*size_D+1:4*size_D));sum(Distr(4*size_D+1:5*size_D))];

for rel=1:5 
    b_time(rel,1)=dist_rel(rel)^(-1)*Distr((rel-1)*size_D+1:rel*size_D)'*Vec_vwork((rel-1)*size_D+1:rel*size_D);
end
model_moments=[model_moments; b_time];
%====================%
%Moment 25-27:
%avg time per age
%====================%
ag=agrid+1;
Vec_vwork_o=[];Vec_vwork_m=[];Vec_vwork_y=[]; dis_o=[];dis_m=[];dis_y=[];
for as=1:3:size(Distr,1)/(3*ag)
    Vec_vwork_o=[Vec_vwork_o; Vec_vwork((as-1)*(ag)+1: as*ag)];
    dis_o=[dis_o; Distr((as-1)*ag+1: as*ag)] ;
    
    Vec_vwork_m=[Vec_vwork_m; Vec_vwork((as)*(ag)+1: (as+1)*ag)];
    dis_m=[dis_m; Distr((as)*ag+1: (as+1)*ag)] ;
    
    Vec_vwork_y=[Vec_vwork_y; Vec_vwork((as+1)*(ag)+1: (as+2)*ag)];
    dis_y=[dis_y; Distr((as+1)*ag +1: (as+2)*ag )] ;
end
time_o=(sum(dis_o))^(-1) * dis_o' *Vec_vwork_o;
time_m=(sum(dis_m))^(-1) * dis_m' *Vec_vwork_m;
time_y=(sum(dis_y))^(-1) * dis_y' *Vec_vwork_y;

model_moments=[model_moments; time_y;time_m;time_o];

%====================%
%Moment 28-29: [UPDATE 21,22]
%avg time per church
%====================%
Vec_vwork_h=[];Vec_vwork_l=[];dis_h=[];dis_l=[];

for as=1:2:size(Distr,1)/(3*ag*3*2)
    Vec_vwork_h=[Vec_vwork_h; Vec_vwork((as-1)*(3*ag*3)+1: as*3*ag*3)];
    dis_h=[dis_h; Distr((as-1)*(3*ag*3)+1: as*3*ag*3)] ;
    
    Vec_vwork_l=[Vec_vwork_l; Vec_vwork((as)*(3*ag*3)+1: (as+1)*3*ag*3)];
    dis_l=[dis_l; Distr((as)*(3*ag*3)+1: (as+1)*3*ag*3)] ;
    
    
end
time_h=(sum(dis_h))^(-1) * dis_h' *Vec_vwork_h;
time_l=(sum(dis_l))^(-1) * dis_l' *Vec_vwork_l;
model_moments=[model_moments; time_l;time_h];
 
%====================%
%Moment 30-35:
%reg time on ---
%====================%

%R explanatory , reg_don dependent variable
% R6=[];reg_time=[]; %R the matrix for variable: pen prot other mid old high_crim
% for i=1:size(Distr,1)
%     num_obs=round(observation*Distr(i));
%     if num_obs>0
%         reg_time=[reg_time; Vec_vwork_std(i)* ones(num_obs,1)]; %creating the dependent variable
%         
%         r_k6=[zeros(1,6) 1]; %constant is the final term
%         %if i<=size_D %catholic  
%         if i>size_D && i<=2*size_D %pentecostal
%             r_k6(1)=1;
%         elseif i>2*size_D && i<=3*size_D %protestant
%             r_k6(2)=1;
%         elseif i>3*size_D && i<=4*size_D %other religion
%             r_k6(3)=1;
%         end
%         
%         z1=rem(i,ag*3); %age group
%         if z1>ag && z1<=2*ag %mid age
%             r_k6(4)=1;
%         elseif z1<=ag %old
%             r_k6(5)=1;
%  
%         end
%         
%         z2=rem(i,ag*3*3*2); %highcrime=1
%         if z2<=ag*3*3
%             r_k6(6)=1;
%         end
%         
%         R6=[R6; ones(num_obs,1)*r_k6];
%     end      
% end
%  reg_coeff6=regress(reg_time,R6); %careful to drop the final estimated coefficient, cause it's the constant
%  model_moments=[model_moments; reg_coeff6(1:6)];  

%====================%
%Moment 36:avg pray
%====================%
Avg_pray=Distr'*Vec_pray; %mean
model_moments=[model_moments;Avg_pray];
%====================%
%Moment 37:
%cor pray w income
%====================%
Avg_asset=Distr'*Vec_asset; %mean
var_asset=Distr'*(Vec_asset-Avg_asset).^2; %variance
sd_asset=var_asset^(0.5);
var_pray=Distr'*(Vec_pray-Avg_pray).^2; %variance
sd_pray=var_pray^(0.5);

%corr_ap=(sd_asset*sd_pray)^(-1)* Distr'*((Vec_pray - Avg_pray).*( Vec_asset-Avg_asset));
%model_moments=[model_moments;corr_ap];

%====================%
%Moment 38-41:
%avg pray per religion
%====================%
% standardize pray time
Vec_pray_std = (Vec_pray - Avg_pray)/sd_pray;
size_D=size(Distr,1)/5; %bcs we have 4 religions
%dist_rel=[sum(Distr(1:size_D)); sum(Distr(size_D+1:2*size_D));sum(Distr(1+2*size_D:3*size_D));sum(Distr(3*size_D+1:4*size_D));sum(Distr(4*size_D+1:5*size_D))];
dist_rel=[sum(Distr(1:size_D)); sum(Distr(size_D+1:2*size_D));sum(Distr(1+2*size_D:3*size_D));sum(Distr(3*size_D+1:4*size_D));sum(Distr(4*size_D+1:5*size_D))];

for rel=1:5 
    b_pray(rel,1)=dist_rel(rel)^(-1)*Distr((rel-1)*size_D+1:rel*size_D)'*Vec_pray((rel-1)*size_D+1:rel*size_D);
end
model_moments=[model_moments; b_pray];
%====================%
%Moment 42-44:
%avg pray per age
%====================%
ag=agrid+1;
Vec_pray_o=[];Vec_pray_m=[];Vec_pray_y=[]; dis_o=[];dis_m=[];dis_y=[];
for as=1:3:size(Distr,1)/(3*ag)
    Vec_pray_o=[Vec_pray_o; Vec_pray((as-1)*(ag)+1: as*ag)];
    dis_o=[dis_o; Distr((as-1)*ag+1: as*ag)] ;
    
    Vec_pray_m=[Vec_pray_m; Vec_pray((as)*(ag)+1: (as+1)*ag)];
    dis_m=[dis_m; Distr((as)*ag+1: (as+1)*ag)] ;
    
    Vec_pray_y=[Vec_pray_y; Vec_pray((as+1)*(ag)+1: (as+2)*ag)];
    dis_y=[dis_y; Distr((as+1)*ag +1: (as+2)*ag )] ;
end
pray_o=(sum(dis_o))^(-1) * dis_o' *Vec_pray_o;
pray_m=(sum(dis_m))^(-1) * dis_m' *Vec_pray_m;
pray_y=(sum(dis_y))^(-1) * dis_y' *Vec_pray_y;

model_moments=[model_moments; pray_y;pray_m; pray_o];

%====================%
%Moment 45-46: [UPDATED 32,33]
%avg pray per church
%====================%
Vec_pray_h=[];Vec_pray_l=[];dis_h=[];dis_l=[];

for as=1:2:size(Distr,1)/(3*ag*3*2)
    Vec_pray_h=[Vec_pray_h; Vec_pray((as-1)*(3*ag*3)+1: as*3*ag*3)];
    dis_h=[dis_h; Distr((as-1)*(3*ag*3)+1: as*3*ag*3)] ;
    
    Vec_pray_l=[Vec_pray_l; Vec_pray((as)*(3*ag*3)+1: (as+1)*3*ag*3)];
    dis_l=[dis_l; Distr((as)*(3*ag*3)+1: (as+1)*3*ag*3)] ;
    
    
end
pray_h=(sum(dis_h))^(-1) * dis_h' *Vec_pray_h;
pray_l=(sum(dis_l))^(-1) * dis_l' *Vec_pray_l;
model_moments=[model_moments; pray_l;pray_h];


%====================%
%Moment 47-52:
%reg pray on ---
%====================%
%R explanatory , reg_don dependent variable
% R7=[];reg_pray=[]; %R the matrix for variable: pen prot other mid old high_crim
% for i=1:size(Distr,1)
%     num_obs=round(observation*Distr(i));
%     if num_obs>0
%         reg_pray=[reg_pray; Vec_pray_std(i)* ones(num_obs,1)]; %creating the dependent variable
%         
%         r_k7=[zeros(1,6) 1]; %constant is the final term
%         %if i<=size_D %catholic  
%         if i>size_D && i<=2*size_D %pentecostal
%             r_k7(1)=1;
%         elseif i>2*size_D && i<=3*size_D %protestant
%             r_k7(2)=1;
%         elseif i>3*size_D && i<=4*size_D %other religion
%             r_k7(3)=1;
%         end
%         
%         z1=rem(i,ag*3); %age group
%         if z1>ag && z1<=2*ag %mid age
%             r_k7(4)=1;
%         elseif z1<=ag %old
%             r_k7(5)=1;
%  
%         end
%         
%         z2=rem(i,ag*3*3*2); %highcrime=1
%         if z2<=ag*3*3
%             r_k7(6)=1;
%         end
%         
%         R7=[R7; ones(num_obs,1)*r_k7];
%     end      
% end
%  reg_coeff7=regress(reg_pray,R7); %careful to drop the final estimated coefficient, cause it's the constant
%  model_moments=[model_moments; reg_coeff7(1:6)];  

%====================%
%Moment 53-56:
%Community help:phi_r
%====================%
%size_D=size(Distr,1)/5; %bcs we have 5 religions
%dist_rel defined as above
%S_r   = (zetta*Vec_donation.^theta1+(1-zetta)*Vec_vwork.^theta1).^(1/theta1);
Ach_vec = repmat([Ach(1); Ach(2)], 10, 1); %altering between Ach values 10 time - starting with high (I think - at least with crime this was the order)
Ach_vec = kron(Ach_vec, ones(3*3*12, 1)); % (educ*age*asset)

S_r   =Ach_vec.* s_bar^alpha.*(zetta*Vec_donation.^theta1+(1-zetta)*Vec_vwork.^theta1).^(1/theta1);
Phi_r = [];
for rel=1:5
    Phi_r((rel-1)*size_D+1:rel*size_D) = S_r((rel-1)*size_D+1:rel*size_D)./(S_r((rel-1)*size_D+1:rel*size_D)+phi_0(rel)); %community help
end
Phi_r = Phi_r';

for rel=1:5 
    community_help(rel,1)=dist_rel(rel)^(-1)*Distr((rel-1)*size_D+1:rel*size_D)'*Phi_r((rel-1)*size_D+1:rel*size_D) ;
end
model_moments=[model_moments; community_help];

%====================%
%Moment 57-59:
%Community help per age
%====================%
%dis_o dis_m dis_y
Vec_ch_o=[];Vec_ch_m=[];Vec_ch_y=[];
for as=1:3:size(Distr,1)/(3*ag)
    Vec_ch_o=[Vec_ch_o; Phi_r((as-1)*(ag)+1: as*ag)];
    
    Vec_ch_m=[Vec_ch_m; Phi_r((as)*(ag)+1: (as+1)*ag)];
    
    Vec_ch_y=[Vec_ch_y; Phi_r((as+1)*(ag)+1: (as+2)*ag)];
    
end
ch_o=(sum(dis_o))^(-1) * dis_o' *Vec_ch_o;
ch_m=(sum(dis_m))^(-1) * dis_m' *Vec_ch_m;
ch_y=(sum(dis_y))^(-1) * dis_y' *Vec_ch_y;

model_moments=[model_moments; ch_y;ch_m;ch_o];

%====================%
%Moment 60-61 [UPDATED: 42, 43]:
%Community help per church
%====================%
Vec_ch_h=[];Vec_ch_l=[];
%dis_h;dis_l

for as=1:2:size(Distr,1)/(3*ag*3*2)
    Vec_ch_h=[Vec_ch_h; Phi_r((as-1)*(3*ag*3)+1: as*3*ag*3)];
    
    Vec_ch_l=[Vec_ch_l; Phi_r((as)*(3*ag*3)+1: (as+1)*3*ag*3)];
    
end
ch_h=(sum(dis_h))^(-1) * dis_h' *Vec_ch_h;
ch_l=(sum(dis_l))^(-1) * dis_l' *Vec_ch_l;
model_moments=[model_moments; ch_l;ch_h];

%====================%
%Moment:
%Avg. Working time
%====================%
Avg_work=Distr'*Vec_work; %mean
model_moments=[model_moments;Avg_work];

%====================%
%Moment 62:
%cor don w com help job
%====================%
%Avg_donation
%var_donation=Distr'*(Vec_donation-Avg_donation).^2; %variance
%sd_donation=var_donation^(0.5);
Avg_ch=Distr'*Phi_r; %mean
var_ch=Distr'*(Phi_r-Avg_ch).^2; %variance
sd_ch=var_ch^(0.5);

%corr_dch=(sd_ch*sd_donation)^(-1)* Distr'*((Vec_donation - Avg_donation).*( Phi_r-Avg_ch)); %correlation donation and community help
%model_moments=[model_moments;corr_dch];

%====================%
%Moment 63-66:
%cor don w com help job
%per religion
%====================%

%size_D=size(Distr,1)/5; %bcs we have 5 religions
%dist_rel=[sum(Distr(1:size_D)); sum(Distr(size_D+1:2*size_D));sum(Distr(1+2*size_D:3*size_D));sum(Distr(3*size_D+1:4*size_D));sum(Distr(4*size_D+1:5*size_D))];
%b_don(rel,1): avg donation per religion
% for rel=1:4 %CHECK
%     %sd of donation per religion
%     var_b_don(rel,1)=dist_rel(rel)^(-1)*Distr((rel-1)*size_D+1:rel*size_D)'* (Vec_donation((rel-1)*size_D+1:rel*size_D)-b_don(rel,1)).^2;
%     sd_b_don(rel,1)=var_b_don(rel,1)^(0.5);
%     %sd of community help per religion
%     b_ch(rel,1)=dist_rel(rel)^(-1)*Distr((rel-1)*size_D+1:rel*size_D)'*Phi_r((rel-1)*size_D+1:rel*size_D);
%     var_b_ch(rel,1)=dist_rel(rel)^(-1)*Distr((rel-1)*size_D+1:rel*size_D)'* (Phi_r((rel-1)*size_D+1:rel*size_D)-b_ch(rel,1)).^2;
%     sd_b_ch(rel,1)=var_b_ch(rel,1)^(0.5);
%     %correlation
%     corr_b_donch(rel,1)=(sd_b_don(rel,1)*sd_b_ch(rel,1))^(-1)*dist_rel(rel)^(-1)* Distr((rel-1)*size_D+1:rel*size_D)'*((Vec_donation((rel-1)*size_D+1:rel*size_D) - b_don(rel,1)).*( Phi_r((rel-1)*size_D+1:rel*size_D)-b_ch(rel,1))); %correlation donation and community help
%     
% end
%model_moments=[model_moments; corr_b_donch];

%====================%
%Moment 67-69:
%cor don w com help job
%per age group
%====================%
%dis_o dis_m dis_y:distributions
%ch_o ch_m ch_y : avg per age group
%don_o :avg donation per age group

%sd of donations per age group
var_d_o=(sum(dis_o))^(-1)* dis_o'*(Vec_donation_o-don_o).^2;
sd_d_o=var_d_o^(0.5);
var_d_m= (sum(dis_m))^(-1)*dis_m'*(Vec_donation_m-don_m).^2;
sd_d_m=var_d_m^(0.5);
var_d_y= (sum(dis_y))^(-1)*dis_y'*(Vec_donation_y-don_y).^2;
sd_d_y=var_d_y^(0.5);
%sd of ch per age group
var_ch_o=(sum(dis_o))^(-1)*dis_o'* (Vec_ch_o-ch_o).^2;
sd_ch_o=var_ch_o^(0.5);
var_ch_m=(sum(dis_m))^(-1)*dis_m'* (Vec_ch_m-ch_m).^2;
sd_ch_m=var_ch_m^(0.5);
var_ch_y=(sum(dis_y))^(-1)*dis_y'* (Vec_ch_y-ch_y).^2;
sd_ch_y=var_ch_y^(0.5);


% corr_donch_o=(sd_ch_o*sd_d_o)^(-1)*(sum(dis_o))^(-1)*  dis_o'*((Vec_ch_o-ch_o).*(Vec_donation_o-don_o)); %(sum(dis_o))^(-1)* : is it needed?
% corr_donch_m=(sd_ch_m*sd_d_m)^(-1)*(sum(dis_m))^(-1)*  dis_m'*((Vec_ch_m-ch_m).*(Vec_donation_m-don_m)); %(sum(dis_o))^(-1)* : is it needed?
% corr_donch_y=(sd_ch_y*sd_d_y)^(-1)*(sum(dis_y))^(-1)*  dis_y'*((Vec_ch_y-ch_y).*(Vec_donation_y-don_y)); %(sum(dis_o))^(-1)* : is it needed?
%     
% 
% model_moments=[model_moments; corr_donch_y;corr_donch_m;corr_donch_o];


%====================%
%Moment 70:
%cor time,com help job
%====================%
%Avg_time  %Avg_ch
%var_time
%sd_time  sd_ch

% corr_tch=(sd_ch*sd_time)^(-1)* Distr'*((Vec_vwork - Avg_time).*( Phi_r-Avg_ch)); %correlation donation and community help
% model_moments=[model_moments;corr_tch];

%====================%
%Moment 71-74:
%cor time com help job
%per religion
%====================%
%size_D=size(Distr,1)/5; %bcs we have 5 religions
%dist_rel
%b_time(rel,1): avg time per religion
%b_ch sd_b_ch  avg

for rel=1:5 
   %sd of time per religion
    
   var_b_time(rel,1)=dist_rel(rel)^(-1)*Distr((rel-1)*size_D+1:rel*size_D)'* (Vec_vwork((rel-1)*size_D+1:rel*size_D)-b_time(rel,1)).^2;
   sd_b_time(rel,1)=var_b_time(rel,1)^(0.5);
    
   
   %correlation
%    corr_b_timech(rel,1)=(sd_b_time(rel,1)*sd_b_ch(rel,1))^(-1)*dist_rel(rel)^(-1)* Distr((rel-1)*size_D+1:rel*size_D)'*((Vec_vwork((rel-1)*size_D+1:rel*size_D) - b_time(rel,1)).*( Phi_r((rel-1)*size_D+1:rel*size_D)-b_ch(rel,1))); %correlation donation and community help
    
end
% model_moments=[model_moments; corr_b_timech];


%====================%
%Moment 75-77:
%cor time com help job
%per age group
%====================%
%dis_o dis_m dis_y:distributions
%ch_o ch_m ch_y : avg per age group
%time_o :avg time per age group
%sd_ch_o 

%sd of donations per age group
var_time_o=(sum(dis_o))^(-1)* dis_o'*(Vec_vwork_o-time_o).^2;
sd_time_o=var_time_o^(0.5);
var_time_m= (sum(dis_m))^(-1)*dis_m'*(Vec_vwork_m-time_m).^2;
sd_time_m=var_time_m^(0.5);
var_time_y= (sum(dis_y))^(-1)*dis_y'*(Vec_vwork_y-time_y).^2;
sd_time_y=var_time_y^(0.5);


% corr_timech_o=(sd_ch_o*sd_time_o)^(-1)*(sum(dis_o))^(-1)*  dis_o'*((Vec_ch_o-ch_o).*(Vec_vwork_o-time_o)); 
% corr_timech_m=(sd_ch_m*sd_time_m)^(-1)*(sum(dis_m))^(-1)*  dis_m'*((Vec_ch_m-ch_m).*(Vec_vwork_m-time_m)); 
% corr_timech_y=(sd_ch_y*sd_time_y)^(-1)*(sum(dis_y))^(-1)*  dis_y'*((Vec_ch_y-ch_y).*(Vec_vwork_y-time_y)); 
%     

% model_moments=[model_moments; corr_timech_y;corr_timech_m;corr_timech_o];



%====================%
%Moment 78-85:
%reg ch on ---
%====================%

% R2=[];reg_ch=[]; %R2 the matrix for variable: don  time time*don pen prot other mid old 
% for i=1:size(Distr,1)
%     num_obs=round(observation*Distr(i));
%     if num_obs>0
%         reg_ch=[reg_ch; Phi_r(i)* ones(num_obs,1)]; %creating the dependent variable
%         
%         r_k2=[zeros(1,8) 1]; %constant is the final term
%         r_k2(1)=Vec_donation(i);
%         r_k2(2)=Vec_vwork(i);
%         r_k2(3)=Vec_donation(i)*Vec_vwork(i);
% 
%         if i>size_D && i<=2*size_D %pentecostal
%             r_k2(4)=1;
%         elseif i>2*size_D && i<=3*size_D %protestant
%             r_k2(5)=1;
%         elseif i>3*size_D && i<=4*size_D %other religion
%             r_k2(6)=1;
%         %elseif i>4*size_D 
%         end
%         
%         z1=rem(i,ag*3);
%         if z1>ag && z1<=2*ag %mid age
%             r_k2(7)=1;
%         elseif z1<=ag %old
%             r_k2(8)=1;
%  
%         end
% 
%         R2=[R2; ones(num_obs,1)*r_k2];
%     end      
% end
%  reg_coeff2=regress(reg_ch,R2);
%  model_moments=[model_moments; reg_coeff2(1:8)];
%====================%
%Moment 86-89:
%Outside help:phi_b
%====================%
%size_D=size(Distr,1)/5; %bcs we have 5 religions
%dist_rel defined as above

%Phi_b = S_r./(S_r+phi_exp); %community help
% Phi_b=[];
% for rel=1:4
%     Phi_b((rel-1)*size_D+1:rel*size_D) = S_r((rel-1)*size_D+1:rel*size_D)./(S_r((rel-1)*size_D+1:rel*size_D)+phi_exp(rel)); %community help
% end
% Phi_b = Phi_b';
% for rel=1:4 
%     out_help(rel,1)=dist_rel(rel)^(-1)*Distr((rel-1)+1:rel*size_D)'*Phi_b((rel-1)+1:rel*size_D) ;
% end
% model_moments=[model_moments; out_help];
%====================%
%Moment 90-92:
%out help per age
%====================%
%dis_o dis_m dis_y
% Vec_oh_o=[];Vec_oh_m=[];Vec_oh_y=[];
% for as=1:3:size(Distr,1)/(3*ag)
%     Vec_oh_o=[Vec_oh_o; Phi_b((as-1)*(ag)+1: as*ag)];
%     
%     Vec_oh_m=[Vec_oh_m; Phi_b((as)*(ag)+1: (as+1)*ag)];
%     
%     Vec_oh_y=[Vec_oh_y; Phi_b((as+1)*(ag)+1: (as+2)*ag)];
%     
% end
% oh_o=(sum(dis_o))^(-1) * dis_o' *Vec_oh_o;
% oh_m=(sum(dis_m))^(-1) * dis_m' *Vec_oh_m;
% oh_y=(sum(dis_y))^(-1) * dis_y' *Vec_oh_y;
% 
% model_moments=[model_moments; oh_y;oh_m;oh_o];
%====================%
%Moment 93-94:
%out help per crime
%====================%
% Vec_oh_h=[];Vec_oh_l=[];
% %dis_h;dis_l
% 
% for as=1:2:size(Distr,1)/(3*ag*3*2)
%     Vec_oh_h=[Vec_oh_h; Phi_b((as-1)*(3*ag*3)+1: as*3*ag*3)];
%     
%     Vec_oh_l=[Vec_oh_l; Phi_b((as)*(3*ag*3)+1: (as+1)*3*ag*3)];
%     
% end
% oh_h=(sum(dis_h))^(-1) * dis_h' *Vec_oh_h;
% oh_l=(sum(dis_l))^(-1) * dis_l' *Vec_oh_l;
% model_moments=[model_moments; oh_l;oh_h];
% 
% %====================%
% %Moment 95:
% %cor don w out help
% %====================%
% %Avg_donation
% %var_donation=Distr'*(Vec_donation-Avg_donation).^2; %variance
% %sd_donation=var_donation^(0.5);
% Avg_oh=Distr'*Phi_b; %mean
% var_oh=Distr'*(Phi_b-Avg_oh).^2; %variance
% sd_oh=var_oh^(0.5);
% 
% corr_doh=(sd_oh*sd_donation)^(-1)* Distr'*((Vec_donation - Avg_donation).*( Phi_b-Avg_oh)); %correlation donation and community help
% model_moments=[model_moments;corr_doh];
% 
% %====================%
% %Moment 96-99:
% %cor don w out help 
% %per religion
% %====================%
% %size_D=size(Distr,1)/5; %bcs we have 5 religions
% %dist_rel
% %b_don(rel,1): avg donation per religion
% %sd_b_don(rel,1) : sd for religion
% for rel=1:4 
%     %sd of community help per religion
%     b_oh(rel,1)=dist_rel(rel)^(-1)*Distr((rel-1)*size_D+1:rel*size_D)'*Phi_b((rel-1)*size_D+1:rel*size_D);
%     var_b_oh(rel,1)=dist_rel(rel)^(-1)*Distr((rel-1)*size_D+1:rel*size_D)'* (Phi_b((rel-1)*size_D+1:rel*size_D)-b_oh(rel,1)).^2;
%     sd_b_oh(rel,1)=var_b_oh(rel,1)^(0.5);
%     %correlation
%     corr_b_donoh(rel,1)=(sd_b_don(rel,1)*sd_b_oh(rel,1))^(-1)*dist_rel(rel)^(-1)* Distr((rel-1)*size_D+1:rel*size_D)'*((Vec_donation((rel-1)*size_D+1:rel*size_D) - b_don(rel,1)).*( Phi_b((rel-1)*size_D+1:rel*size_D)-b_oh(rel,1))); %correlation donation and community help
%     
% end
% 
% model_moments=[model_moments; corr_b_donoh];
%====================%
%Moment 100-102:
%cor don w out help
%per age group
%====================%
%dis_o dis_m dis_y:distributions
%ch_o ch_m ch_y : avg per age group
%don_o :avg donation per age group
%sd_d_o :sd of donations per age group

%sd of ch per age group
% var_oh_o = (sum(dis_o))^(-1)*dis_o'* (Vec_oh_o-oh_o).^2;
% sd_oh_o  = var_oh_o^(0.5);
% var_oh_m = (sum(dis_m))^(-1)*dis_m'* (Vec_oh_m-oh_m).^2;
% sd_oh_m  = var_oh_m^(0.5);
% var_oh_y = (sum(dis_y))^(-1)*dis_y'* (Vec_oh_y-oh_y).^2;
% sd_oh_y  = var_oh_y^(0.5);
% 
% corr_donoh_o=(sd_oh_o*sd_d_o)^(-1)*(sum(dis_o))^(-1)*  dis_o'*((Vec_oh_o-oh_o).*(Vec_donation_o-don_o)) ;
% corr_donoh_m=(sd_oh_m*sd_d_m)^(-1)*(sum(dis_m))^(-1)*  dis_m'*((Vec_oh_m-oh_m).*(Vec_donation_m-don_m)) ;
% corr_donoh_y=(sd_oh_y*sd_d_y)^(-1)*(sum(dis_y))^(-1)*  dis_y'*((Vec_oh_y-oh_y).*(Vec_donation_y-don_y));
%     
% 
% model_moments=[model_moments; corr_donoh_y;corr_donoh_m;corr_donoh_o];

%====================%
%Moment 103:
%cor time w out help
%====================%
%Avg_time
%sd_time=var_donation^(0.5);
%Avg_oh   sd_oh

% corr_timeoh=(sd_oh*sd_time)^(-1)* Distr'*((Vec_vwork - Avg_time).*( Phi_b-Avg_oh)); %correlation donation and community help
% model_moments=[model_moments;corr_timeoh];

%====================%
%Moment 104-107:
%cor time w out help 
%per religion
%====================%
%size_D=size(Distr,1)/5; %bcs we have 5 religions
%dist_rel
%b_time(rel,1): avg donation per religion
%sd_b_time(rel,1) : sd for religion
% b_oh sd_b_oh
% for rel=1:4 
%     
%     %correlation
%    corr_b_timeoh(rel,1)=(sd_b_time(rel,1)*sd_b_oh(rel,1))^(-1)*dist_rel(rel)^(-1)* Distr((rel-1)*size_D+1:rel*size_D)'*((Vec_vwork((rel-1)*size_D+1:rel*size_D) - b_time(rel,1)).*( Phi_b((rel-1)*size_D+1:rel*size_D)-b_oh(rel,1))); %correlation donation and community help
%     
% end
% 
% model_moments=[model_moments; corr_b_timeoh];
%====================%
%Moment 108-110:
%cor time out help
%per age group
%====================%
%dis_o dis_m dis_y:distributions
%ch_o ch_m ch_y : avg per age group
%don_o :avg donation per age group
%sd_d_o :sd of donations per age group

%sd of ch per age group: sd_oh_o

% corr_timeoh_o=(sd_oh_o*sd_time_o)^(-1)*(sum(dis_o))^(-1)*  dis_o'*((Vec_oh_o-oh_o).*(Vec_vwork_o-time_o)) ;
% corr_timeoh_m=(sd_oh_m*sd_time_m)^(-1)*(sum(dis_m))^(-1)*  dis_m'*((Vec_oh_m-oh_m).*(Vec_vwork_m-time_m)) ;
% corr_timeoh_y=(sd_oh_y*sd_time_y)^(-1)*(sum(dis_y))^(-1)*  dis_y'*((Vec_oh_y-oh_y).*(Vec_vwork_y-time_y));
%     
% 
% model_moments=[model_moments; corr_timeoh_y;corr_timeoh_m;corr_timeoh_o];

%====================%
%Moment 111-118:
%reg oh on ---
%====================%

% R3=[];reg_oh=[]; %R2 the matrix for variable: don  time time*don pen prot other mid old 
% for i=1:size(Distr,1)
%     num_obs=round(observation*Distr(i));
%     if num_obs>0
%         reg_oh=[reg_oh; Phi_b(i)* ones(num_obs,1)]; %creating the dependent variable
%         
%         r_k3=[zeros(1,8) 1]; %constant is the final term
%         r_k3(1)=Vec_donation(i);
%         r_k3(2)=Vec_vwork(i);
%         r_k3(3)=Vec_donation(i)*Vec_vwork(i);
% 
%         if i>size_D && i<=2*size_D %pentecostal
%             r_k3(4)=1;
%         elseif i>2*size_D && i<=3*size_D %protestant
%             r_k3(5)=1;
%         elseif i>3*size_D && i<=4*size_D %other religion
%             r_k3(6)=1;
%         %elseif i>4*size_D 
%         end
%         
%         z1=rem(i,ag*3);
%         if z1>ag && z1<=2*ag %mid age
%             r_k3(7)=1;
%         elseif z1<=ag %old
%             r_k3(8)=1;
%  
%         end
% 
%         R3=[R3; ones(num_obs,1)*r_k3];
%     end      
% end
%  reg_coeff3=regress(reg_oh,R3);
%  model_moments=[model_moments; reg_coeff3(1:8)];
%====================%
%Moment 139-147:
%reg oh on ---
%====================%
 
%  R4=[];reg_oh2=[]; %R2 the matrix for variable: don  time time*don pen prot other mid old highcrime
% for i=1:size(Distr,1)
%     num_obs=round(observation*Distr(i));
%     if num_obs>0
%         reg_oh2=[reg_oh2; Phi_b(i)* ones(num_obs,1)]; %creating the dependent variable
%         
%         r_k4=[zeros(1,9) 1]; %constant is the final term
%         r_k4(1)=Vec_donation(i);
%         r_k4(2)=Vec_vwork(i);
%         r_k4(3)=Vec_donation(i)*Vec_vwork(i);
% 
%         if i>size_D && i<=2*size_D %pentecostal
%             r_k4(4)=1;
%         elseif i>2*size_D && i<=3*size_D %protestant
%             r_k4(5)=1;
%         elseif i>3*size_D && i<=4*size_D %other religion
%             r_k4(6)=1;
%         %elseif i>4*size_D 
%         end
%         
%         z1=rem(i,ag*3);
%         if z1>ag && z1<=2*ag %mid age
%             r_k4(7)=1;
%         elseif z1<=ag %old
%             r_k4(8)=1;
%  
%         end
%         z2=rem(i,ag*3*3*2); %highcrime=1
%         if z2<=ag*3*3
%             r_k4(9)=1;
%         end
% 
%         R4=[R4; ones(num_obs,1)*r_k4];
%     end      
% end
%  reg_coeff4=regress(reg_oh2,R4);
%  model_moments=[model_moments; reg_coeff4(1:9)];
 
%====================%
%Moment 148:
%cor don w afterlife
%====================%
%Avg_donation
%var_donation=Distr'*(Vec_donation-Avg_donation).^2; %variance
%sd_donation=var_donation^(0.5);
%Prob_after = S_r./(S_r+phi_2); %prob afterlife
% Prob_after = [];
% for rel=1:4
%     Prob_after((rel-1)*size_D+1:rel*size_D) = S_r((rel-1)*size_D+1:rel*size_D)./(S_r((rel-1)*size_D+1:rel*size_D)+phi_2(rel)); %community help
% end
% Prob_after = Prob_after';
% 
% Avg_af=Distr'*Prob_after; %mean
% var_af=Distr'*(Prob_after-Avg_af).^2; %variance
% sd_af=var_af^(0.5);
% 
% corr_daf=(sd_af*sd_donation)^(-1)* Distr'*((Vec_donation - Avg_donation).*( Prob_after-Avg_af)); %correlation donation and community help
% model_moments=[model_moments;corr_daf];

%====================%
%Moment 149-152:
%cor don w afterlife
%per religion
%====================%
%size_D=size(Distr,1)/5; %bcs we have 5 religions
%dist_rel
%b_don(rel,1): avg donation per religion
%sd_b_don(rel,1) : sd for religion
% for rel=1:4 
%     %sd of afterlife
%     b_af(rel,1)=dist_rel(rel)^(-1)*Distr((rel-1)*size_D+1:rel*size_D)'*Prob_after((rel-1)*size_D+1:rel*size_D);
%     var_b_af(rel,1)=dist_rel(rel)^(-1)*Distr((rel-1)*size_D+1:rel*size_D)'* (Prob_after((rel-1)*size_D+1:rel*size_D)-b_af(rel,1)).^2;
%     sd_b_af(rel,1)=var_b_af(rel,1)^(0.5);
%     %correlation
%     corr_b_donaf(rel,1)=(sd_b_don(rel,1)*sd_b_af(rel,1))^(-1)*dist_rel(rel)^(-1)* Distr((rel-1)*size_D+1:rel*size_D)'*((Vec_donation((rel-1)*size_D+1:rel*size_D) - b_don(rel,1)).*( Prob_after((rel-1)*size_D+1:rel*size_D)-b_af(rel,1))); %correlation donation and community help
%     
% end
% 
% model_moments=[model_moments; corr_b_donaf];
%====================%
%Moment 153-155:
%cor don w out af
%per age group
%====================%
%dis_o dis_m dis_y:distributions
%don_o :avg donation per age group
%sd_d_o :sd of donations per age group
% Vec_af_o=[];Vec_af_m=[];Vec_af_y=[];
% for as=1:3:size(Distr,1)/(3*ag)
%     Vec_af_o=[Vec_af_o; Prob_after((as-1)*(ag)+1: as*ag)];
%     
%     Vec_af_m=[Vec_af_m; Prob_after((as)*(ag)+1: (as+1)*ag)];
%     
%     Vec_af_y=[Vec_af_y; Prob_after((as+1)*(ag)+1: (as+2)*ag)];    
% end
% af_o=(sum(dis_o))^(-1) * dis_o' *Vec_af_o;
% af_m=(sum(dis_m))^(-1) * dis_m' *Vec_af_m;
% af_y=(sum(dis_y))^(-1) * dis_y' *Vec_af_y;
% %sd of ch per age group
% var_af_o = (sum(dis_o))^(-1)*dis_o'* (Vec_af_o-af_o).^2;
% sd_af_o  = var_af_o^(0.5);
% var_af_m = (sum(dis_m))^(-1)*dis_m'* (Vec_af_m-af_m).^2;
% sd_af_m  = var_af_m^(0.5);
% var_af_y = (sum(dis_y))^(-1)*dis_y'* (Vec_af_y-af_y).^2;
% sd_af_y  = var_af_y^(0.5);
% 
% corr_donaf_o=(sd_af_o*sd_d_o)^(-1)*(sum(dis_o))^(-1)*  dis_o'*((Vec_af_o-af_o).*(Vec_donation_o-don_o)) ;
% corr_donaf_m=(sd_af_m*sd_d_m)^(-1)*(sum(dis_m))^(-1)*  dis_m'*((Vec_af_m-af_m).*(Vec_donation_m-don_m)) ;
% corr_donaf_y=(sd_af_y*sd_d_y)^(-1)*(sum(dis_y))^(-1)*  dis_y'*((Vec_af_y-af_y).*(Vec_donation_y-don_y)) ;
%     
% 
% model_moments=[model_moments; corr_donaf_y;corr_donaf_m;corr_donaf_o];


%====================%
%Moment 156:
%cor time w afterlife
%====================%
%Avg_time  Avg_af
%sd_time  sd_af

% corr_timeaf=(sd_af*sd_time)^(-1)* Distr'*((Vec_vwork - Avg_time).*( Prob_after-Avg_af)); %correlation time and afterlife
% model_moments=[model_moments;corr_timeaf];

%====================%
%Moment 157-160:
%cor time w afterlife
%per religion
%====================%
%size_D=size(Distr,1)/5; %bcs we have 5 religions
%dist_rel
%b_time(rel,1): avg donation per religion
%b_af  sd_b_af
%sd_b_time(rel,1) : sd for religion
% for rel=1:4 
%     %correlation
%    corr_b_timeaf(rel,1)=(sd_b_time(rel,1)*sd_b_af(rel,1))^(-1)*dist_rel(rel)^(-1)* Distr((rel-1)*size_D+1:rel*size_D)'*((Vec_vwork((rel-1)*size_D+1:rel*size_D) - b_time(rel,1)).*( Prob_after((rel-1)*size_D+1:rel*size_D)-b_af(rel,1))); 
% end
% 
% model_moments=[model_moments; corr_b_timeaf];
%====================%
%Moment 161-163:
%cor time w  afterlfe
%per age group
%====================%
%dis_o dis_m dis_y:distributions
%don_o :avg donation per age group
%sd_d_o :sd of donations per age group
%af_o  avg     sd_af_o 

% corr_timeaf_o=(sd_af_o*sd_time_o)^(-1)*(sum(dis_o))^(-1)*  dis_o'*((Vec_af_o-af_o).*(Vec_vwork_o-time_o)) ;
% corr_timeaf_m=(sd_af_m*sd_time_m)^(-1)*(sum(dis_m))^(-1)*  dis_m'*((Vec_af_m-af_m).*(Vec_vwork_m-time_m)) ;
% corr_timeaf_y=(sd_af_y*sd_time_y)^(-1)*(sum(dis_y))^(-1)*  dis_y'*((Vec_af_y-af_y).*(Vec_vwork_y-time_y)) ;
%     
% 
% model_moments=[model_moments; corr_timeaf_y;corr_timeaf_m;corr_timeaf_o];
%%

%====================%
%Moment 164:
%cor pray w afterlife
%====================%
%Avg_pray  Avg_af
%sd_pray  sd_af

% corr_prayaf=(sd_af*sd_pray)^(-1)* Distr'*((Vec_pray - Avg_pray).*( Prob_after-Avg_af)); %correlation pray and afterlife
% model_moments=[model_moments;corr_prayaf];

%====================%
%Moment 165-168:
%cor pray w afterlife
%per religion
%====================%
%size_D=size(Distr,1)/5; %bcs we have 5 religions
%dist_rel
%b_pray(rel,1): avg donation per religion
%b_af  sd_b_af
%sd_b_pray(rel,1) : sd for religion

% for rel=1:4 
%    %sd of time per religion
%    var_b_pray(rel,1)=dist_rel(rel)^(-1)*Distr((rel-1)*size_D+1:rel*size_D)'* (Vec_pray((rel-1)*size_D+1:rel*size_D)-b_pray(rel,1)).^2;
%    sd_b_pray(rel,1)=var_b_pray(rel,1)^(0.5);
%     %correlation
%    corr_b_prayaf(rel,1)=(sd_b_pray(rel,1)*sd_b_af(rel,1))^(-1)*dist_rel(rel)^(-1)* Distr((rel-1)*size_D+1:rel*size_D)'*((Vec_pray((rel-1)*size_D+1:rel*size_D) - b_pray(rel,1)).*( Prob_after((rel-1)*size_D+1:rel*size_D)-b_af(rel,1))); 
% end
% 
% model_moments=[model_moments; corr_b_prayaf];
%====================%
%Moment 169-171:
%cor pray w  afterlfe
%per age group
%====================%
%dis_o dis_m dis_y:distributions
%don_o :avg donation per age group
%sd_d_o :sd of donations per age group
%af_o  avg     sd_af_o 

% var_pray_o=(sum(dis_o))^(-1)* dis_o'*(Vec_pray_o-pray_o).^2;
% sd_pray_o=var_pray_o^(0.5);
% var_pray_m= (sum(dis_m))^(-1)*dis_m'*(Vec_pray_m-pray_m).^2;
% sd_pray_m=var_pray_m^(0.5);
% var_pray_y= (sum(dis_y))^(-1)*dis_y'*(Vec_pray_y-pray_y).^2;
% sd_pray_y=var_pray_y^(0.5);
% 
% corr_prayaf_o=(sd_af_o*sd_pray_o)^(-1)*(sum(dis_o))^(-1)*  dis_o'*((Vec_af_o-af_o).*(Vec_pray_o-pray_o)) ;
% corr_prayaf_m=(sd_af_m*sd_pray_m)^(-1)*(sum(dis_m))^(-1)*  dis_m'*((Vec_af_m-af_m).*(Vec_pray_m-pray_m)) ;
% corr_prayaf_y=(sd_af_y*sd_pray_y)^(-1)*(sum(dis_y))^(-1)*  dis_y'*((Vec_af_y-af_y).*(Vec_pray_y-pray_y)) ;
%     
% 
% model_moments=[model_moments; corr_prayaf_y;corr_prayaf_m;corr_prayaf_o];
% 
% 
%%
%====================%
%Moment 172-183:
%reg oh on ---
%====================%
% R5=[];reg_oh3=[]; %R2 the matrix for variable: don  time time*don pen prot other mid old highcrime
% for i=1:size(Distr,1)
%     num_obs=round(observation*Distr(i));
%     if num_obs>0
%         reg_oh3=[reg_oh3; Phi_b(i)* ones(num_obs,1)]; %creating the dependent variable
%         
%         r_k4=[zeros(1,12) 1]; %constant is the final term
%         r_k4(1)=Vec_donation(i);
%         r_k4(2)=Vec_vwork(i);
%         r_k4(3)=Vec_pray(i);
%         r_k4(4)=Vec_donation(i)*Vec_vwork(i);
%         r_k4(5)=Vec_donation(i)*Vec_pray(i);
%         r_k4(6)=Vec_vwork(i)*Vec_pray(i);
%         r_k4(7)=Vec_donation(i)*Vec_pray(i)*Vec_vwork(i);
% 
% 
%         if i>size_D && i<=2*size_D %pentecostal
%             r_k4(8)=1;
%         elseif i>2*size_D && i<=3*size_D %protestant
%             r_k4(9)=1;
%         elseif i>3*size_D && i<=4*size_D %other religion
%             r_k4(10)=1;
%         %elseif i>4*size_D 
%         end
%         
%         z1=rem(i,ag*3);
%         if z1>ag && z1<=2*ag %mid age
%             r_k4(11)=1;
%         elseif z1<=ag %old
%             r_k4(12)=1;
%         end
%  
% 
% 
%         R5=[R5; ones(num_obs,1)*r_k4];
%     end      
% end
%  reg_coeff5=regress(reg_oh3,R5);
%  model_moments=[model_moments; reg_coeff5(1:12)];
 
% %====================%
% %Moment 184-191:
% % avg employment transitions
% % per age group and education
% %====================%
% % first average over different religions
% Vec_trans_avg_rel =dist_rel(1)*Vec_trans(1:size_D)+dist_rel(2)*Vec_trans(size_D+1:(2*size_D))+dist_rel(3)*Vec_trans((2*size_D)+1:3*size_D)+dist_rel(4)*Vec_trans(3*size_D+1:4*size_D);
% % average over crime (50/50)
% Vec_trans_avg_rel_crime = [];
% size_crime = length(Vec_trans_avg_rel)/2;
% Vec_trans_avg_rel_crime = 0.5*Vec_trans_avg_rel(1:size_crime)+0.5*Vec_trans_avg_rel(1+size_crime:2*size_crime);
% % average over income
% Vec_trans_avg_rel_crime_income = [];
% for i=1:(length(Vec_trans_avg_rel_crime)/length(DAsset))
%     Vec_trans_avg_rel_crime_income = [Vec_trans_avg_rel_crime_income;DAsset*Vec_trans_avg_rel_crime(1+(i-1)*length(DAsset):i*length(DAsset))];
% end
% 
%  model_moments=[model_moments;Vec_trans_avg_rel_crime_income];
% 

end







        
        