% 22.02.2012
% Rotina de labeling de conectividade 4
% Vinícius Angiolucci Reis

% Limpa variáveis de ambiente
clear all, close all, clc

% Carrega a figura que será
% analisada
bw = imread('geometricas.png');
bw = ~bw;

% Verifica o tamanho da figura
[i, j] = size( bw );

% Cria uma matriz que servirá de mapa para tags
tagmap = zeros(i,j);

%Cria uma matriz que guardará quais tags são iguais
if mod(i*j, 2) == 0
	tagvector_size = ( i * j ) / 2;
else
	tagvector_size = (( i * j ) + 1 ) / 2;
end
tagtable = zeros(tagvector_size, 1);

% Definições de variáveis
total_pixels = 0;		% Área total da figura
regions = 0;			% Regiões identificadas
currtag = 1;			% Caractere de tag atual
maxtag  = 0;			% Armazena a última tag
value_old = 0;			% temporário para troca
value_new = 0;			% temporário para troca

% Percorre a figura identificando regiões
for I = 1:i
	for J = 1:j
		if bw(I,J) == 0
			total_pixels = total_pixels + 1;
			if ( I == 1 ) | ( J == 1)
				if ( I == 1 ) & ( J ~= 1 )
					% checa somente J-1
					if bw(I,J-1) == 0
						tagmap(I,J) = tagmap(I,J-1);
					else
						tagmap(I,J) = currtag;
						currtag = currtag + 1;
					end
					
				else
					if ( I == 1 ) & ( J == 1 )
						% não checa, é o primeiro pixel e atribuí-se
						% a primeira tag a este pixel
						tagmap(I,J) = currtag;
						currtag = currtag + 1;
					else
						% I ~= 1 e J = 1
						% checa somente I-1
						if bw(I-1,J) == 0
							tagmap(I,J) = tagmap(I-1,J);
						else
							tagmap(I,J) = currtag;
							currtag = currtag + 1;
						end
					end
				end
			else
				% I e J ão diferentes de 1, checagem normal
				%------------------------------------------
				if bw(I,J-1) == 0
					if bw(I-1,J) == 0
						if tagmap(I,J-1) ~= tagmap(I-1,J)
						%------------------------------------------------
						% Verifica a maior tag e faz ela apontar para a 
						% menor
							if tagmap(I,J-1) > tagmap(I-1,J)
								tagtable( (tagmap(I,J-1)),1 ) = tagmap(I-1,J);
							else
								tagtable( (tagmap(I-1,J)),1 ) = tagmap(I,J-1);
							end
							%tagtable(1,1) = 0;
							tagmap(I,J) = tagmap(I,J-1);
						%-------------------------------------------------	
						else
							tagmap(I,J) = tagmap(I,J-1);
						end
					else
						tagmap(I,J) = tagmap(I,J-1);
					end
				else
					if bw(I-1,J) == 0
						tagmap(I,J) = tagmap(I-1,J);
					else
						tagmap(I,J) = currtag;
						currtag = currtag + 1;
					end
				end
				%------------------------------------------
			end
		end
	end
end

% Percorre novamente toda a figura, trocando as tags
% de mesma classe de equivalência
sprintf('ajustando labels...')
for I = 1:i
	for J = 1:j
		if bw(I,J) == 0
			currtag = tagmap(I,J);
			
			while 1 == 1
				if tagtable(currtag,1) ~= 0
					currtag = tagtable(currtag,1);
				else
					break;
				end
			end
			tagmap(I,J) = currtag;
		end
	end
end

% Atualiza as tags de modo a ficarem em sequencia linear de inteiros
% TAG 1 = 1, TAG 2 = 2 ...

% limpa a tabela de equivalências de tags para 
% novo uso
tagtable = zeros(tagvector_size, 1);

sampletag = 0;
maxtag = 0;
for I = 1:i
	for J = 1:j
		if bw(I,J) == 0
			tagtable(tagmap(I,J),1) = tagtable(tagmap(I,J),1) + 1;
			sampletag = tagmap(I,J);
			if sampletag > maxtag
				maxtag = sampletag;
			end
		end
	end
end

for k = 1:maxtag
	if tagtable(k,1) == 0
		value_new = k;
		for l = k:maxtag
			if tagtable(l,1) ~= 0;
				value_old = l;
				
				for I = 1:i
					for J = 1:j
						if tagmap(I,J) == value_old
							tagmap(I,J) = value_new;
						end
					end
				end
				
				tagtable(k,1) = tagtable(l,1);
				tagtable(l,1) = 0;
				%regions = k;
				break;
			end
		end
	end
end

% ----------------------------------------------
sampletag = 0;
maxtag = 0;
for I = 1:i
	for J = 1:j
		if bw(I,J) == 0
			sampletag = tagmap(I,J);
			if sampletag > maxtag
				maxtag = sampletag;
			end
		end
	end
end
regions = maxtag;
% ----------------------------------------------

% Apresentação dos dados
for I = 1:regions
	sprintf('Região %d área:\t%d',I,tagtable(I,1))
end
sprintf('\n....\n%d Regiões identificadas totalizando %d pixels.\n', regions, total_pixels )

% Limpeza dos dados
% clear all, close all

figure,imshow(mat2gray(tagmap))
colormap(hsv)
