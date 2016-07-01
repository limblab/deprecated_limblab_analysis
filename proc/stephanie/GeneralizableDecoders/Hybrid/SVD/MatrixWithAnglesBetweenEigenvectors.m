MatrixWithAnglesBetweenEigenvectors

         % h_svd  i_svd  m_svd  i_pca  m_pca
% h_svd
% i_svd
% m_svd
% i_pca
% m_pca 


EV = [h_svd i_svd m_svd i_pca m_pca];
for i = 1:5
    for j = 1:5
        angleMatrix(i,j) = dot(EV(:,i),EV(:,j));
    end
end



