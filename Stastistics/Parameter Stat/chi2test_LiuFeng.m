function [p, Q]= chi2test_LiuFeng(x)
	
% Usage: [p, Q]= chi2test(x)
% 
% The chi-squared test. 
% 
% Given a number of samples this function tests the hypothesis that the samples are 
% independent. If Q > chi2(p, nu), the hypothesis is rejected. 
% 
% Each column represents a variables, each row a sample.
% 
% If you find any errors, please let me know:
% 
% ARGUMENTS:
% x     Absolut numbers.
% p     The prob ability value, calculated from Q.
% Q     The resulting Q-value.
% 
% EXAMPLE 1
% In region A, 324 of 556 cows were red, whereas in region B 98 of 260 were red.
% [p, Q]= chi2test_LiuFeng([324, 556-324; 98, 260-98])
% p=
%    4.2073e-08
% Q=
%    30.0515
% With an error risk of about 4e-08, we can claim that the samples are independent.
% 
% EXAMPLE 2
% Throw two different dices to see if they have the same probability of 1 (and 2, 3, 4, 5, 6).
% We don't check if they are symetrical, only if the both behave in the same way.
% [p,Q] = chi2test([15,10; 7,11; 9,7; 20,15; 26,21; 19,16])
% p=
%    0.8200
% Q =
%    2.2059
% The dices don't significantly behave differently. That is, they seem to behave in the same way.
%
% HISTORY:    v.1.0, first working version, 2007-08-30.
% 
% COPYRIGHT:  (c) 2007 Peder Axensten. Use at own risk.

% KEYWORDS:   chi-squared test, chi-squared, chi2, test

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	% Check the arguments.
	if(nargin ~= 1),			error('One and only one argument required!');					end
	if(ndims(x) ~= 2),			error('The argument (x) must be a 2d matrix!');					end
	if(any(size(x) == 1)),		error('The argument (x) must be a 2d matrix!');					end
	if(any(~isreal(x))),		error('All values of the argument (x) must be real values!');	end
	
	% Calculate Q = sum( (a-np*)^2/(np*(1-p*)) )
	s=		size(x, 1);
	r=		size(x, 2);
	np=		sum(x, 2)/sum(sum(x)) * sum(x);		% p=sum(x, 2)/sum(sum(x)) and n=sum(x)
	Q=		sum(sum((x-np).^2./(np)));
	
	% Calculate cdf of chi-squared to Q. Degrees of freedom, v, is (r-1)*(s-1).
	p=		1 - gammainc(Q/2, (r-1)*(s-1)/2);
end
