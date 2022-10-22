%##########################################################################
%####################          EXEMPLOS DE MP          ####################
%##########################################################################


% Entrada da matriz ciclo-corrente com adição da 4a coluna indicando se
% corrente é conhecida/não.

clear all

MP=[1	35	0
    2	34	35
    3	29	34
    4	33	34
    5	5	20
    6	12	32
    7	11	3
    8	6	32
    9	3	12
    10	3	33
    11	10	11
    12	21	10
    13	32	13
    14	13	6
    15	6	33
    16	20	21
    17	31	23
    18	36	31
    19	0	31
    20	30	25
    21	23	30
    22	5	30
    23	25	5
    24	36	27
    25	35	36
    26	4	9
    27	19	7
    28	7	28
    29	18	28
    30	2	18
    31	17	2
    32	2	29
    33	16	17
    34	15	16
    35	14	15
    36	28	19
    37	7	29
    38	9	14
    39	27	22
    40	0	27
    41	26	24
    42	22	26
    43	4	26
    44	24	4];

% MP=[1 0 1 1
%     2 1 2 0
%     3 2 3 0
%     4 3 1 0
%     5 3 4 0
%      6 4 5 0
%      7 4 7 0
%      8 5 6 0
%      9 7 5 0
%      10 6 4 0
%      11 6 8 0
%      12 7 8 0
%      13 8 2 0
%      14 8 0 1];


%##########################################################################
%##########################################################################
%##########################################################################


[correntes_de_abertura, ciclos] = ciclor_func(MP);



%##########################################################################
%##########################################################################
%##########################################################################


function [A,so_ciclo] = ciclor_func(MP)
    
    
    %######################################################################
    
    
    % Variáveis:
    O = MP (:,2);
    D = MP (:,3);
    
    verificacao_final = 1;
    contador_dois = 1;
    contador_um = 1;
    correntes{1} = [];
    
    
    %######################################################################
    
    
    % Mapeia correntes-destino (em L) para cada corrente-origem conhecida
    [R1,C1,V1] = find(O==0);
    linhas_R1 = size(R1,1);
    for a = 1:linhas_R1
        L{a} = MP(R1(a),[1 3]);
    end
    
    
    %######################################################################
    
    
    % Registra todas possiblidades de ciclo 
    while verificacao_final ~= 0 % Até todas listas criadas serem zeradas
        colunas_L = size(L,2); % listas existentes
        % Adiciona em cada lista a corrente e destino do equipamento
        for b = 1:colunas_L
            % Origem em MP igual a destino em L, sendo destino
            % e origem diferentes de zero
            [R2{b},C2,V2] = find(O==L{b}(end,2) & D~=0 & O~=0);
            linhas_R2 = size(R2{b},1);
            % Se houverem correntes continua
            if linhas_R2 ~= 0
                % Cria tantas listas quantas correntes de saída (C&D) 
                % houverem e adiciona na posicao+1
                posicao = size(L,2);
                [L] = criar(linhas_R2,L{b},L,posicao);
                linhas_Lb = size(L{b},1);
                % Zera a lista na posicao original
                L{b} = zeros(linhas_Lb,2);
                fim = linhas_R2+posicao;
                for c = (posicao+1):fim% Para cada corrente de saida
                    destino_L = L{c}(:,2);
                    correntes_L = L{c}(:,1);
                    % Verifica se fecha ciclo (Se destino_L está na lista)
                    [R3,C3,V3] = find(MP(R2{b}(contador_um),3)==destino_L);
                    linhas_R3 = length (R3);
                    % Insere C e D em L
                    L{c}(end+1,[1 2]) = MP(R2{b}(contador_um),[1 3]);
                    if linhas_R3~=0
                        ciclo{contador_dois} = L{c}';
                        so_ciclo{contador_dois} = L{c}(R3+1:end,:)';
                        contador_dois=contador_dois+1;
                        linhas_L = length(L{c});
                        L{c} = zeros(linhas_L,2);% Elimina ciclo de L
                    end
                    contador_um=contador_um+1;
                end
                contador_um=1;
            end
        end
        % Verifica se ainda há listas em L e se há correntes nestas
        colunas_L=size(L,2);
        for d = 1:colunas_L
            [R4{d},C4,V4] = find(O==L{d}(end,2) & D~=0 & O~=0);
            verificacao_vazio(d)= 1-isempty (R4{d});
        end
        verificacao_final=sum(verificacao_vazio,2);
    end
    
    
    %######################################################################
    
    
    % Extrai dos ciclos C&D as correntes de início e fim de cada ciclo, 
    % e as correntes entre estas
    for kk = 1:length(ciclo)
        for ii=1:length(ciclo{kk})
           num = find(ciclo{kk}(2,:)==ciclo{kk}(2,ii));
           if size(num)>1
           break
           end
        end
        ciclo_corr{kk}=ciclo{kk}(1,num(1)+1:num(2));
    end
    
    
    %######################################################################
    
    
    % Ordena vetores ciclo_corr
    for i = 1 : length (ciclo_corr)
        contador_tres = 0;
        verificacao_while = 1;
        ciclo_corr_ord{i} = zeros(1,length(ciclo_corr{i}));
        while verificacao_while ~= 0
            [r1,c1,v1]=find(ciclo_corr{i}==max(ciclo_corr{i}));
            ciclo_corr_ord{i}(end-contador_tres)=ciclo_corr{i}(c1(1));
            ciclo_corr{i}(c1(1))=0;
            contador_tres=contador_tres+1;
            verificacao_while=sum(ciclo_corr{i});
        end
    
    end
    
    
    %######################################################################
   
    
    % Elimina ciclos repetidos
    contador_quatro=1;
    for i=1:length(ciclo_corr_ord)
        colunas_ciclo_corr_ord=length(ciclo_corr_ord{i});
        if isempty(ciclo_corr_ord{i})==0
            correntes{contador_quatro}=ciclo_corr_ord{i}(1:end);
            for k=1:length(ciclo_corr_ord)
                colunas_ciclo_corr_ord_a_comparar=length(ciclo_corr_ord{kk});
                if  colunas_ciclo_corr_ord==colunas_ciclo_corr_ord_a_comparar
                    verifica_igualdade=(ciclo_corr_ord{i}==ciclo_corr_ord{kk});
                    if sum(verifica_igualdade)==1*length(verifica_igualdade)
                       ciclo_corr_ord{kk}=[];
                    end
                end
            end
            ciclo_corr_ord{i}(1:end)=[];
            contador_quatro=contador_quatro+1;
        end
    end
    
    
    %######################################################################
    
    
    % Cria matriz ciclo corrente
    for kk=1:length(correntes)
        MCC(kk,correntes{kk})=1;
    end
    
    
    %######################################################################
    
    
    % Seleciona correntes de abertura
    nca=1;
    while nca~=0
        if max(max(MCC))~=0
        C = sum(MCC,1);
        catemp=find(max(C)==C);
        A(nca)=catemp(1);
            for kk=1:size(MCC,1)
                if MCC(kk,A(nca))==1
                    MCC(kk,:)=0;
                end
            end
            nca = nca + 1;
        else
            nca=0;
        end
    end

end


