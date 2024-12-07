function M_g = kOmegaSquare(Omega_g,theta,Parameter)
% function to calculate M_g with the k * Omega^2 rule 
% adjusted by fle (15.11.24)

    k = Parameter.VSC.k;
    M_g = k * Omega_g^2;
 

end

