%% Transfer Learning Using GoogLeNet
% This example shows how to use transfer learning to retrain GoogLeNet, a pretrained convolutional
% neural network, to classify a new set of images.

%%
% Unzip and load the new images as an image datastore. The size of the
% images is 227-by-227 pixels, but GoogLeNet expects images of size
% 224-by-224 pixels. Assign a read function to the image datastore that
% automatically resizes the images. Divide the data into training and
% validation data sets. Use 70% of the images for training and 30% for
% validation.
imgPath='D:\myMatlabCode\private_code\Fig_transfer learning';
images = imageDatastore(imgPath,'IncludeSubfolders',true,'LabelSource','foldernames');
images.ReadFcn = @(loc)imresize(imread(loc),[224,224]);
[trainImages,valImages] = splitEachLabel(images,0.7,'randomized');


%%
% Load the pretrained GoogLeNet network. If the Neural Network Toolbox(TM)
% Model _for GoogLeNet Network_ is not installed, then the software
% provides a download link. GoogLeNet is trained on more than one million
% images and can classify images into 1000 object categories.
net = googlenet;

%%
% Extract the layer graph from the trained network and plot the layer
% graph.
lgraph = layerGraph(net);
figure('Units','normalized','Position',[0.1 0.1 0.8 0.8]);
plot(lgraph)

%%
% To retrain GoogLeNet to classify new images, replace the last three
% layers of the network. These three layers of the network, with the names
% |'loss3-classifier'|, |'prob'|, and |'output'|, contain the information
% of how to combine the features that the network extracts into class
% probabilities and labels. Add three new layers, a fully connected layer,
% a softmax layer, and a classification output layer, to the layer graph.
% Set the final fully connected layer to have the same size as the number
% of classes in the new data set (5, in this example). To learn faster in
% the new layers than in the transferred layers, increase the learning rate
% factors of the fully connected layer.
lgraph = removeLayers(lgraph, {'loss3-classifier','prob','output'});

numClasses = numel(categories(trainImages.Labels));
newLayers = [
    fullyConnectedLayer(numClasses,'Name','fc','WeightLearnRateFactor',20,'BiasLearnRateFactor', 20)
    softmaxLayer('Name','softmax')
    classificationLayer('Name','classoutput')];
lgraph = addLayers(lgraph,newLayers);


%%
% Connect the last of the transferred layers remaining in the network
% (|'pool5-drop_7x7_s1'|) to the new layers. To check that the new layers
% are correctly connected, plot the new layer graph and zoom in on the last
% layers of the network.
lgraph = connectLayers(lgraph,'pool5-drop_7x7_s1','fc');

figure('Units','normalized','Position',[0.3 0.3 0.4 0.4]);
plot(lgraph)
ylim([0,10])

%%
% Specify the training options, including learning rate, mini-batch size,
% and validation data.
options = trainingOptions('sgdm',...
    'MiniBatchSize',10,...
    'MaxEpochs',3,...
    'InitialLearnRate',1e-4,...
    'VerboseFrequency',1,...
    'ValidationData',valImages,...
    'ValidationFrequency',3);

%%
% Train the network using the training data.
net = trainNetwork(trainImages,lgraph,options);

%%
% Classify the validation images using the fine-tuned network, and
% calculate the classification accuracy.
val= imageDatastore(valImages.Files(1),'IncludeSubfolders',true,'LabelSource','foldernames');
val.ReadFcn = @(loc)imresize(imread(loc),[224,224]);
predictedLabels = classify(net,val);
% accuracy = mean(predictedLabels == valImages.Labels);
