function [orignalALFF,ALFF,frequentVector,uniqueFrequencyDomainSignal]=lc_alff(AllVolume,ASamplePeriod,...
                                                            nDimTimePoints,LowCutoff,HighCutoff,CUTNUMBER)
% 这段代码修改自dpasf，请务必尊重原创作者严超赣研究员，并引用dpabi或者dpasf等
% output:
    % ALFF:2D ALFF value
    % frequentVector=频率向量，作图时的x轴
    % uniqueFrequencyDomainSignal：频域信号向量，作图时的y轴
%%
    % Get the frequency index
    sampleFreq 	 = 1/ASamplePeriod;
    sampleLength = nDimTimePoints;
    paddedLength = 2^nextpow2(sampleLength);
    if (LowCutoff >= sampleFreq/2) % All high included
        idx_LowCutoff = paddedLength/2 + 1;
    else % high cut off, such as freq > 0.01 Hz
        idx_LowCutoff = ceil(LowCutoff * paddedLength * ASamplePeriod + 1);
        % Change from round to ceil: idx_LowCutoff = round(LowCutoff *paddedLength *ASamplePeriod + 1);
    end
    if (HighCutoff>=sampleFreq/2)||(HighCutoff==0) % All low pass
        idx_HighCutoff = paddedLength/2 + 1;
    else % Low pass, such as freq < 0.08 Hz
        idx_HighCutoff = fix(HighCutoff *paddedLength *ASamplePeriod + 1);
        % Change from round to fix: idx_HighCutoff	=round(HighCutoff *paddedLength *ASamplePeriod + 1);
    end


    % Detrend before fft as did in the previous alff.m
    %AllVolume=detrend(AllVolume);
    % Cut to be friendly with the RAM Memory
%     SegmentLength = ceil(size(AllVolume,2) / CUTNUMBER);
%     for iCut=1:CUTNUMBER
%         if iCut~=CUTNUMBER
%             Segment = (iCut-1)*SegmentLength+1 : iCut*SegmentLength;
%         else
%             Segment = (iCut-1)*SegmentLength+1 : size(AllVolume,2);
%         end
%         AllVolume(:,Segment) = detrend(AllVolume(:,Segment));
%     end


    % Zero Padding
    AllVolume = [AllVolume;zeros(paddedLength -sampleLength,size(AllVolume,2))]; %padded with zero
    orginalFrequencyDomainSignal=zeros(size(AllVolume));
    fprintf('\n\t Performing FFT ...');
    %AllVolume = 2*abs(fft(AllVolume))/sampleLength;
    % Cut to be friendly with the RAM Memory
    SegmentLength = ceil(size(AllVolume,2) / CUTNUMBER);
    for iCut=1:CUTNUMBER
        if iCut~=CUTNUMBER
            Segment = (iCut-1)*SegmentLength+1 : iCut*SegmentLength;
        else
            Segment = (iCut-1)*SegmentLength+1 : size(AllVolume,2);
        end
        AllVolume(:,Segment) = 2*abs(fft(AllVolume(:,Segment)))/sampleLength;
        orginalFrequencyDomainSignal(:,Segment)= fft(AllVolume(:,Segment))/sampleLength;
        fprintf('.');
    end
    %%
    ALFF = mean(AllVolume(idx_LowCutoff:idx_HighCutoff,:));
    frequentVector = sampleFreq/2*linspace(0,1,paddedLength/2+1);
    uniqueFrequencyDomainSignal = orginalFrequencyDomainSignal(1:paddedLength/2+1,:,:);
    orignalALFF=AllVolume(1:paddedLength/2+1,:,:);
    figure
    plot(frequentVector,orignalALFF,'-','LineWidth',1.5,'color',[1 0.5 0]);
    stem(frequentVector,orignalALFF,'LineWidth',1.5,'color',[1 0.5 0])
    xlabel('Frequency (Hz)','FontSize',15)
    ylabel('Amplitude','FontSize',15)
    set(gca, 'XTick',[0.01,0.1,0.2] );
    box off
    plot(signal,'-','LineWidth',1.5,'color',[1 0.5 0]);
    xlabel('Time point','FontSize',15)
    ylabel('BOLD signal','FontSize',15)
    set(gca, 'XTick',[0 50 100 150 200 240] );
    box off
    
%     figure
%     f2=plot(frequentVector,uniqueFrequencyDomainSignal,'--.')
    

end