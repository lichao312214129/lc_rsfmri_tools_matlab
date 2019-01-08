obj = VideoReader('J:\老舅\视频/VID_20180302_144906.mp4');%输入视频位置
numFrames = obj.NumberOfFrames;% 帧的总数
 % 读取前N帧
 for k = round(obj.NumberOfFrames/3) :round(obj.NumberOfFrames/2)
     frame = read(obj,k);%读取第几帧
    % imshow(frame);%显示帧
      imwrite(frame,strcat('J:\老舅\视频\',num2str(k),'.jpg'),'jpg');% 保存帧
 end