pause(5)
t = java.awt.Toolkit.getDefaultToolkit();
rec = java.awt.Rectangle(t.getScreenSize());
robo = java.awt.Robot;
t = java.awt.Toolkit.getDefaultToolkit();
rec = java.awt.Rectangle(t.getScreenSize());
image = robo.createScreenCapture(rec);
filehandle = java.io.File('screen.png');
javax.imageio.ImageIO.write(image,'png',filehandle);
a=imread('screen.png');
imshow(a),hold on