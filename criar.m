function [L]=criar(N_criar, lista_atual,L,posicao)
fim=N_criar+posicao;
for i=(posicao+1):fim
    L{i}=lista_atual(:,:);
end