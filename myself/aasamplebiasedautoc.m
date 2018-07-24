function[r,xs]=aasamplebiasedautoc(x,lg)
%this function finds the biased autocorrelation function
%with lag from 0 to lg; it is recommended that lg is 20-30% of
%N;
N=length(x);%x=data;lg=lag;
for m=1:lg
for n=1:N+1-m
xs(m,n)=x(n-1+m);
end;
end;
r1=xs*x';
r=r1'./N