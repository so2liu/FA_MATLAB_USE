clear;close all;clc;

% load('isi.mat','Y');
% Y = double(Y);

load('pn_50db.mat');
Y = Y/mean(abs(Y));
[output, error, coefficient] = rls_cma(Y, 15);
constellation_plot(Y, output);