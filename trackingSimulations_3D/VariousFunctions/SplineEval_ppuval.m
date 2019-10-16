function [y,yp,ypp] = SplineEval_ppuval(pp_y,x,flag)

% Note that pp_y is a data structure generated by the 'spline' command
%                   pp_y = spline(x,y)
% pp_y is the piecewise polynomial form of a cubic spline curve and
% contains the cubic spline coefficients a1, a2, a3, and a4 for each
% segment of the piecewise polynomial curve, where
%             y = a1*x^3 + a2*x^2 + a3*x + a4
% The cubic spline coefficients for each curve segment are given by
% pp_y.coefs(:,1) = a1 coefficients
% pp_y.coefs(:,2) = a2 coefficients
% pp_y.coefs(:,3) = a3 coefficients
% pp_y.coefs(:,4) = a4 coefficients

% Inputs:
%   pp_y => piecewise polynomial data structure from 'spline' command
%   x    => scalar input value at which y and its derivatives are desired
%   flag => set to 0 for only y as output, 1 for y and its derivatives
%
% Outputs:
%   y    => scalar output value y
%   yp   => dy/dx 
%   ypp  => d^2 y/d x^2
    
% Calculate y at specified value of x using cubic spline coefficients

    y = ppval(pp_y,x);

% Calculate first and second derivatives of y with respect to x
% if flag is passed in as nonzero (e.g., as 1)

    if flag
    
        % yp = 0*x^3 + 3*a1*x^2 + 2*a2*x + a3

        pp_yp = pp_y;
        pp_yp.coefs(:,1) = 0;
        pp_yp.coefs(:,2) = 3*pp_y.coefs(:,1);
        pp_yp.coefs(:,3) = 2*pp_y.coefs(:,2);
        pp_yp.coefs(:,4) = 1*pp_y.coefs(:,3);
        
        yp = ppval(pp_yp,x);
        
        % ypp = 0*x^3 + 0*a1*x^2 + 6*a1*x + 2*a2
        
        pp_ypp = pp_y;
        pp_ypp.coefs(:,1) = 0;
        pp_ypp.coefs(:,2) = 0;
        pp_ypp.coefs(:,3) = 6*pp_y.coefs(:,1);
        pp_ypp.coefs(:,4) = 2*pp_y.coefs(:,2);

        ypp = ppval(pp_ypp,x);
        
    end   
