% input
fileName='D:\myMatlabCode\LC_MVPA\FunWithMATLAB\screen.png';

%%
imgData   = imread(fileName);
ocrResults     = ocr(imgData);
recognizedText = ocrResults.Text;
figure;
imshow(imgData);
text(600, 150, recognizedText, 'BackgroundColor', [1 1 1]);


%%
I = imread(fileName);

% You may also use IMRECT to select a region using a mouse:
figure; imshow(I);
roi = round(getPosition(imrect));

ocrResults = ocr(I, roi);

% Insert recognized text into original image
Iocr = insertText(I, roi(1:2), ocrResults.Text, ...
    'AnchorPoint', 'RightTop', 'FontSize',16);
figure
imshow(Iocr)