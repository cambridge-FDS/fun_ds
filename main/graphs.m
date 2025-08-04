load S_allw S 
amat=params.amat; numb=params.numb;
tl=1; az=2;
subplot(4,2,1);

plot(amat, S{tl,az}.pol_o(1:2:numb,1),'linewidth',1.5,'Color','#bd6513')
hold on
plot(amat, S{tl,az}.pol_o(2:2:numb,1),'--','linewidth',1.5,'Color','#bd6513')
hold on
plot(amat, S{tl,az}.pol_m(1:2:numb,1),'linewidth',1.5,'Color','#172f5f')
hold on
plot(amat, S{tl,az}.pol_m(2:2:numb,1), '--','linewidth',1.5,'Color','#172f5f')
hold on
plot(amat, S{tl,az}.pol_y(1:2:numb,1), 'linewidth',1.5,'Color','#036338')
hold on
plot(amat, S{tl,az}.pol_y(2:2:numb,1),'--','linewidth',1.5,'Color','#036338')
title('Savings','FontName','Palatino Linotype')

subplot(4,2,2);
plot(amat,S{tl,az}. pol_o(1:2:numb,2),'linewidth',1.5,'Color','#bd6513')
hold on
plot(amat, S{tl,az}.pol_o(2:2:numb,2),'--', 'linewidth',1.5,'Color','#bd6513')
hold on
plot(amat, S{tl,az}.pol_m(1:2:numb,2),'linewidth',1.5,'Color','#172f5f')
hold on
plot(amat, S{tl,az}.pol_m(2:2:numb,2),'--','linewidth',1.5,'Color','#172f5f')
hold on
plot(amat, S{tl,az}.pol_y(1:2:numb,2),'linewidth',1.5,'Color','#036338')
hold on
plot(amat, S{tl,az}.pol_y(2:2:numb,2),'--', 'linewidth',1.5,'Color','#036338')
title('Donation','FontName','Palatino Linotype')
% 
subplot(4,2,3);
plot(amat, S{tl,az}.pol_o(1:2:numb,3),'linewidth',1.5,'Color','#bd6513')
hold on
plot(amat, S{tl,az}.pol_o(2:2:numb,3),'--', 'linewidth',1.5,'Color','#bd6513')
hold on
plot(amat, S{tl,az}.pol_m(1:2:numb,3),'linewidth',1.5,'Color','#172f5f')
hold on
plot(amat, S{tl,az}.pol_m(2:2:numb,3),'--','linewidth',1.5,'Color','#172f5f')
hold on
plot(amat, S{tl,az}.pol_y(1:2:numb,3),'linewidth',1.5,'Color','#036338')
hold on
plot(amat, S{tl,az}.pol_y(2:2:numb,3),'--','linewidth',1.5,'Color','#036338')
title('Leisure','FontName','Palatino Linotype')


subplot(4,2,4);
plot(amat, S{tl,az}.pol_o(1:2:numb,4),'linewidth',1.5,'Color','#bd6513')
hold on
plot(amat, S{tl,az}.pol_o(2:2:numb,4),'--', 'linewidth',1.5,'Color','#bd6513')
hold on
plot(amat, S{tl,az}.pol_m(1:2:numb,4),'linewidth',1.5,'Color','#172f5f')
hold on
plot(amat, S{tl,az}.pol_m(2:2:numb,4),'--','linewidth',1.5,'Color','#172f5f')
hold on
plot(amat, S{tl,az}.pol_y(1:2:numb,4), 'linewidth',1.5,'Color','#036338')
hold on
plot(amat, S{tl,az}.pol_y(2:2:numb,4),'--','linewidth',1.5,'Color','#036338')
title('Pray','FontName','Palatino Linotype')
%
subplot(4,2,5);
plot(amat, S{tl,az}.pol_o(1:2:numb,5),'linewidth',1.5,'Color','#bd6513')
hold on
plot(amat, S{tl,az}.pol_o(2:2:numb,5),'--', 'linewidth',1.5,'Color','#bd6513')
hold on
plot(amat, S{tl,az}.pol_m(1:2:numb,5),'linewidth',1.5,'Color','#172f5f')
hold on
plot(amat, S{tl,az}.pol_m(2:2:numb,5),'--','linewidth',1.5,'Color','#172f5f')
hold on
plot(amat, S{tl,az}.pol_y(1:2:numb,5), 'linewidth',1.5,'Color','#036338')
hold on
plot(amat, S{tl,az}.pol_y(2:2:numb,5),'--','linewidth',1.5,'Color','#036338')
title('Time (voluntary work)','FontName','Palatino Linotype')

subplot(4,2,6);
plot(amat, S{tl,az}.pol_o(1:2:numb,6),'linewidth',1.5,'Color','#bd6513')
hold on
plot(amat, S{tl,az}.pol_o(2:2:numb,6),'--', 'linewidth',1.5,'Color','#bd6513')
hold on
plot(amat, S{tl,az}.pol_m(1:2:numb,6),'linewidth',1.5,'Color','#172f5f')
hold on
plot(amat, S{tl,az}.pol_m(2:2:numb,6),'--','linewidth',1.5,'Color','#172f5f')
hold on
plot(amat, S{tl,az}.pol_y(1:2:numb,6),'linewidth',1.5,'Color','#036338')
hold on
plot(amat, S{tl,az}.pol_y(2:2:numb,6),'--','linewidth',1.5,'Color','#036338')
title('Consumption','FontName','Palatino Linotype')

legend('old, unemployed', 'old, employed', 'mid, unemployed', 'mid, employed', 'young, unemployed', 'young, employed','FontName','Palatino Linotype')