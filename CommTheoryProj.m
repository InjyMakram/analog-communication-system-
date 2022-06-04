clc
clear all
close all
%max and min numbers in ID
a=9;
b=1;

%sampling
t=0:0.1:30;
x=a*sin(0.5*b*pi*t);
Ns=2;
Ts=t(1:Ns:end);
Xs=x(1:Ns:end);
N=1:5;
L=2.^N;

%calling the function to get the outputs for all levels(2,4,8,16,32)
for i=1:length(L)
    [Mean(i),VARprac(i),VARtheo(i),SQNRprac(i),SQNRtheo(i),QuantLev]= Quantizer(L(i),a,Xs)
    %[Ts,Xs]=Sampler(t,x,Ns)
end

%plots
figure
plot(L,Mean)
title('AbsoluteMeanQuantizer')

figure
plot(L,VARprac,L,VARtheo)
title('Variance')


figure
plot(L,SQNRprac,L,SQNRtheo)
title('SQNR')


figure 
plot(t,x)
hold on
plot(Ts,QuantLev)
title('Input and Output Signal')

%function el sampler 3shan lw ghayart Ns
function [Ts,Xs]= Sampler(t,x,Ns) 
a=9;
b=1;
t=0:0.1:30;
x=a*sin(0.5*b*pi*t);
Ns=2;
Ts=t(1:Ns:end);
Xs=x(1:Ns:end);

end

function [Mean, VARprac, VARtheo, SQNRprac, SQNRtheo,QuantLev]= Quantizer(L, a, Xs)



%quantizer
Vmax=a;
Vmin=-a;
% L=8;
delta=(Vmax-Vmin)/L;
Xq=Vmin+delta/2 : delta :Vmax-delta/2; %Xq wala t

%encoder loop
for i=1:1:length(Xs)
    error=abs(Xs(i)-Xq);
    SelectLevel=find(error==min(error));
    Select(i)=SelectLevel(1)
    QuantizedLevel(i)=Xq(Select(i));
    EncodedLevels(i)=Select(i)-1
end



%variance
 VARtheo=delta^2/12
 VARprac=var(Xs-QuantizedLevel)

 
 Mean=mean(abs(Xs-QuantizedLevel)) %absolute mean quantizer
 
 %SQNR
 SQNRprac=(Vmax^2)/VARprac
 SQNRtheo=(Vmax^2)/VARtheo

%loop for getting the probabilities 
m=unique(EncodedLevels)
for i=1:1:length(m)
    prob(i)=length(find(EncodedLevels==m(i)))/length(EncodedLevels)
end

%source encoder
[dict,Avg]=huffmandict(m,prob)
SourceEnc=huffmanenco(EncodedLevels,dict)

%source decoder
SourceDec=huffmandeco(SourceEnc,dict)

%decoder loop
for i=1:1:length(SourceDec)
    DecodedLevels(i)=SourceDec(i)+1;
    QuantLev(i)=Xq(DecodedLevels(i));
end

%Efficiency
H=sum(prob.*log2(1./prob))    %Entropy
eff=(H./Avg)*100 %efficiency percentage
n=log2(L)
CR=n/Avg %compression rate
end








