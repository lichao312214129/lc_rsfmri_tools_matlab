function [FC]=fun_dynFC_ana(theta,freq,delta,shift,TR)

[xt,xf,xd,xn]=ndgrid(theta,freq,delta,shift);
xw=xd*2+1;
xw=xw*TR;
const=ones(size(xt));


FC.full.xt=xt;
FC.full.xf=xf;
FC.full.xd=xd;
FC.full.xn=xn;

%FC.full.value=cos(xt) ...
%    + const./(pi*xw.*xf).*cos(2*pi*xf.*xn+xt).*sin(2*pi*xf.*xd) ...
%    - 2*const./(pi*xw.*xf).^2.*cos(2*pi*xf.*xn).*cos(2*pi*xf.*xn+xt).*sin(2*pi*xf.*xd).^2;

FC.full.value=auxFull(xt,xf,xd,xw,xn,TR);

norm1=auxFull(0*xt,xf,xd,xw,xn,TR);
norm2=auxFull(0*xt,xf,xd,xw,xn+xt./(2*pi*TR.*xf),TR);

FC.full.nvalue=FC.full.value./sqrt(abs(norm1.*norm2));

%[xt,xf,xd]=ndgrid(theta,freq,delta);
%xw=xd*2+1;
%const=ones(size(xt));

%FC.approx.xt=xt;
%FC.approx.xf=xf;
%FC.approx.xd=xd;

%FC.approx.mean=cos(xt);
%FC.approx.max=cos(xt)+const./(pi*xw.*xf).*abs(sin(2*pi*xf.*xd))+2*const./(pi*xw.*xf).^2.*sin(2*pi*xf.*xd).^2;
%FC.approx.min=cos(xt)-const./(pi*xw.*xf).*abs(sin(2*pi*xf.*xd))-2*const./(pi*xw.*xf).^2.*sin(2*pi*xf.*xd).^2;

function res=auxFull(xt,xf,xd,xw,xn,TR)
const=ones(size(xt));

%res=cos(xt) ...
%    + const./(pi*xw.*xf).*cos(2*pi*TR*xf.*xn+xt).*sin(2*pi*TR*xf.*xd) ...
%    - 2*const./(pi*xw.*xf).^2.*cos(2*pi*TR*xf.*xn).*cos(2*pi*TR*xf.*xn+xt).*sin(2*pi*TR*xf.*xd).^2;

% fixed version (div/2)
%res=cos(xt) ...
%    + const./(2*pi*xw.*xf).*cos(4*pi*TR*xf.*xn+xt).*sin(4*pi*TR*xf.*xd) ...
%    - 2*const./(pi*xw.*xf).^2.*cos(2*pi*TR*xf.*xn).*cos(2*pi*TR*xf.*xn+xt).*sin(2*pi*TR*xf.*xd).^2;

% fixed version (small window)
res=cos(xt) ...
    + const./(2*pi*xw.*xf).*cos(2*pi*TR*xf.*(2*xn)+xt).*sin(2*pi*TR*xf.*(2*xd+1)) ...
    - 2*const./(pi*xw.*xf).^2.*cos(pi*TR*xf.*(2*xn)).*cos(pi*TR*xf.*(2*xn)+xt).*sin(pi*TR*xf.*(2*xd+1)).^2;
