function Y_knn = AddKNNClassifier(X, Y)
if size(X,1)<size(X,2)
    X = transpose(X);
end

TRAIN_N = 320;
KNN_N = 3;
x_train = X(1:TRAIN_N);
y_train = Y(1:TRAIN_N);

Mdl = fitcknn([real(x_train), imag(x_train)], cellstr(num2str(y_train)), 'NumNeighbors',KNN_N,'Standardize',1);


Y_knn_label = predict(Mdl,[real(X), imag(X)]);
Y_knn = zeros(size(X));
for k = 1:length(Y_knn)
    Y_knn(k) = str2num(cell2mat(Y_knn_label(k)));
end
% Y_knn = str2num(cell2mat(Y_knn_label));
symbol_error_rate = size(find(Y_knn-Y ~= 0), 1)/length(Y)
