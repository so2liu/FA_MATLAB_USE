function[r]=aasampleunbiasedautoc(x,lg)
%this function finds the unbiased autocorrelation function
%from 0 to lag lg;it is recommended that lg is about 20-30% of N;
N=length(x);%x=data;
for m=1:lg
for n=1:N+1-m
xs(m,n)=x(n-1+m);
end;
end;
r1=xs*x';
for m=1:lg
den(m)=N+1-m;
end;
r=r1'./den;
