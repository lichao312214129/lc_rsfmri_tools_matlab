for i=1:length(valImages.Files)
    d=imread(valImages.Files{i});
    imshow(d);
    pause(1);
end