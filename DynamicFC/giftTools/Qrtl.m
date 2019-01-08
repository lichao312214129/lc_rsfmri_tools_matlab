function Y = Qrtl(X)

% if length(size(X))<3 | min(size(X))<2 | sum(X(:)<0)==0
%     error('this is specized function for nonnegative 3D arrays')
% end

Y=NaN.*ones(size(X));

posXinds=find(X>=0);
posX=X(posXinds);
posCutoffs=[0,vals2quantile(posX,[0.25,0.5,0.75]),max(posX(:))+1];
posCutoffs=repmat(posCutoffs,length(posX),1);
posX=repmat(posX,1,5);
pos=posX-posCutoffs;
pos=sign(pos);
pos=diff(pos');
[pos_Qrts,Fj_pos]=find(abs(pos)>=1);
pos_Qrts=pos_Qrts(unique(Fj_pos,'First'));
Y(posXinds)=pos_Qrts;

negXinds = find(X<0);
if (~isempty(negXinds))
    negX=X(negXinds); negX=abs(negX);
    negCutoffs=[0,vals2quantile(abs(negX),[0.25,0.5,0.75]),max(negX(:))+1];
    negCutoffs=repmat(negCutoffs,length(negX),1);
    negX=repmat(negX,1,5);
    neg=negX-negCutoffs;
    neg=sign(neg);
    neg=diff(neg');
    [neg_Qrts,Fj_neg]=find(abs(neg)>=1);
    neg_Qrts=neg_Qrts(unique(Fj_neg,'First'));
    Y(negXinds)=-neg_Qrts;
end
