% Copyright 2016 The MathWorks, Inc.

clear

camera = webcam; % Connect to the camera
nnet = alexnet;  % Load the neural net

while true   
    picture = camera.snapshot;              % Take a picture    
    picture = imresize(picture,[227,227]);  % Resize the picture

    label = classify(nnet, picture);        % Classify the picture
       
    image(picture);     % Show the picture
    title(char(label)); % Show the label
    drawnow;   
end
