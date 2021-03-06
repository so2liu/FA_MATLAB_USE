function    [outputVector,...
             errorVector,...
             coefficientVector] =   ModifiedCMA(input,S)

% according "Modified Constant Modulus Algorithm: Blind Equlization And
% Carrier Phase Recovery Algorithm", Kil Nam Oh
%
%       Implements the Constant-Modulus algorithm for COMPLEX valued data.
%
%   Syntax:
%       [outputVector,errorVector,coefficientVector] = CMA(input,S)
%
%   Input Arguments:
%       . input     : Signal fed into the adaptive filter.          (Column vector)
%       . S         : Structure with the following fields
%           - step                  : Convergence (relaxation) factor.
%           - filterOrderNo         : Order of the FIR filter.
%           - initialCoefficients   : Initial filter coefficients.  (COLUMN vector)
%
%   Output Arguments:
%       . outputVector      :   Store the estimated output of each iteration.   (COLUMN vector)
%       . errorVector       :   Store the error for each iteration.             (COLUMN vector)
%       . coefficientVector :   Store the estimated coefficients for each iteration.
%                               (Coefficients at one iteration are COLUMN vector)
%
%   Authors:
%       . Guilherme de Oliveira Pinto   - guilhermepinto7@gmail.com & guilherme@lps.ufrj.br
%       . Markus Vinícius Santos Lima   - mvsl20@gmailcom           & markus@lps.ufrj.br
%       . Wallace Alves Martins         - wallace.wam@gmail.com     & wallace@lps.ufrj.br
%       . Luiz Wagner Pereira Biscainho - cpneqs@gmail.com          & wagner@lps.ufrj.br
%       . Paulo Sergio Ramirez Diniz    -                             diniz@lps.ufrj.br
%


%   Some Variables and Definitions:
%       . prefixedInput         :   Input is prefixed by nCoefficients -1 random values.
%                                   (The prefix led to a more regular source code)
%
%       . regressor             :   Auxiliar variable. Store the piece of the
%                                   prefixedInput that will be multiplied by the
%                                   current set of coefficients.
%                                   (regressor is a COLUMN vector)
%
%       . nCoefficients         :   FIR filter number of coefficients.
%
%       . nIterations           :   Number of iterations.
%
%       . desiredLevel          :   Defines the level which abs(outputVector(it,1))^2 
%                                   should approach.


%   Initialization Procedure
input = transpose(input);
nCoefficients       =   S.filterOrderNo+1;
nIterations         =   length(input);
desiredLevelR        =   mean(real(input).^4)/mean(real(input).^2);
desiredLevelI        =   mean(imag(input).^4)/mean(imag(input).^2);

%   Pre Allocations
errorVector             =   zeros(nIterations   ,1);
outputVector            =   ones(nIterations   ,1);
coefficientVector       =   zeros(nCoefficients ,(nIterations+1));

%   Initial State Weight Vector
coefficientVector(:,1)  =   S.initialCoefficients;

%   Improve source code regularity
prefixedInput           =   [randn(nCoefficients-1,1)
                             transpose(input)];

%   Body
for it = 1:nIterations,
    regressor                   =   prefixedInput(it+(nCoefficients-1):-1:it,1);

    outputVector(it,1)          =   regressor.'*coefficientVector(:,it);

    
    errorVectorR           =   real(outputVector(it,1))*(real(outputVector(it,1))^2 - desiredLevelR);
    errorVectorI           =   imag(outputVector(it,1))*(imag(outputVector(it,1))^2 - desiredLevelI);
    errorVector(it,1)      =   errorVectorR+1j*errorVectorI;

    coefficientVector(:,it+1)   =   coefficientVector(:,it)-...
                                    (S.step*errorVector(it,1)*conj(regressor));
end
outputVector = conv(input, fliplr(coefficientVector(:,end)), 'same');
%   EOF
