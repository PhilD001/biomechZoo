function data=onehot(data)
y_train=zeros(length(data.y_train),length(data.Conditions));
y_test=zeros(length(data.y_test),length(data.Conditions));
for i=1:length(data.Conditions)
    y_train(data.y_train==i,i)=1;
    y_test(data.y_test==i,i)=1;
end
data.y_train=y_train.';
data.y_test=y_test.';
data.x_train=data.x_train.';
data.x_test=data.x_test.';