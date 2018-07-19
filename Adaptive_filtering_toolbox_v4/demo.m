clc
clear all
close all
t=-pi:0.01:pi;
y1=sin(t)+1.5;
y2=sin(t+pi)+3;
y3=sin(t+pi/5)+3.6;
y4=sin(t+pi/6)+5;
y5=cos(t)+6;
y=[y1',y2',y3',y4',y5'];
figure
h=area(y);
set(h(1),'FaceColor',[0,6,35]/255,'edgecolor',[.8,.8,.8]);
set(h(2),'FaceColor',[40,71,92]/255,'edgecolor',[.8,.8,.8]);
set(h(3),'FaceColor',[74,108,116]/255,'edgecolor',[.8,.8,.8]);
set(h(4),'FaceColor',[139,166,147]/255,'edgecolor',[.8,.8,.8]);
set(h(5),'FaceColor',[240,227,192]/255,'edgecolor',[.8,.8,.8]);
