// Ruan da Fonseca Ramos
// Modelo booleano: Matriz de incidência com contagem de frequência


// documents matrix, already stemmized
M=['O peã e o caval são pec de xadrez. O caval é o melhor do jog.';
'A jog envolv a torr, o peã e o rei.';
'O peã lac o boi';
'Caval de rodei!';
'Polic o jog no xadrez.';
'caval caval caval caval';
'O rat roe roup do rei de roma que era xadrez com um caval']

stopwords=['a'; 'o'; 'e'; 'é'; 'de'; 'do'; 'no'; 'são']

// the search, already stemmized
q='caval xadrez rei';

// separators for getting the tokens
separators=[' ';',';'.';'!';'?']

// normalizing the text
M = convstr(M,"l")
q = convstr(q,"l")
stopwords = convstr(stopwords,"l")

// getting the tokens from the documents
myTokens = []
n = size(M, 'r') // number of lines of matrix M
for i=1:n
    myTokens = [myTokens; tokens(M(i), separators)]
end

// removing the stopwords from the tokens list
m = size(stopwords, 'r')
for i=1:m
    [row] = find(myTokens == stopwords(i))
    myTokens(row,:) = []
end

// removing the stopwords from the search
qTokens = tokens(q, [separators])
sizeq = size(qTokens, 'r')
for i=1:m
    [row] = find(qTokens == stopwords(i))
    qTokens(row,:) = []
end

// removing the stopwords from the documents


// remove repeated tokens
myTokens = unique(myTokens)

// construct the incidence matrix using the M matrix of documents and the tokens
numberTokens = size(myTokens, 'r')
incidenceMatrix = zeros(numberTokens, n)
apearences = 0
for i=1:numberTokens
    for j=1:n
        documentTokens = tokens(M(j) , separators) // each document tokens
        for w=1:size(documentTokens,'r')
            if myTokens(i) == documentTokens(w) then
                apearences = apearences + 1
            end
        end
        //x = find(documentTokens == myTokens(i))
        incidenceMatrix(i,j) = apearences
        apearences = 0
    end
    j = 1
    
end


// getting the rows of the incidence matrix we will need

sizeq = size(qTokens, 'r')
rows = []
for i=1:sizeq
    for j=1:numberTokens
        if qTokens(i) == myTokens(j) then
            positionOfToken = j
            rows = [rows; incidenceMatrix(positionOfToken,:)]
            break
        end
    end
    j = 1
end

// now rows contais the incidenceMatrix rows we need to use for the question

// here we normalize the rows so it will only have 0's and 1's

for i=1:size(rows, 'r')
    for j=1:n
        if rows(i,j) > 1 then
            rows(i,j) = 1
        end
    end
end

// here we make the bit operations
documentsAnd = rows(1,:)
documentsOr = rows(1,:)

for i=2:size(rows, 'r')
    documentsAnd = bitand(documentsAnd, rows(i,:))
end
for i=2:size(rows, 'r')
    documentsOr = bitor(documentsOr, rows(i,:))
end

// printing the final incidence matrix and the final result of the search
for i=1:numberTokens
    printf('%s\t\t', myTokens(i))
    for j=1:n
        printf('%d', incidenceMatrix(i,j))
    end
    printf("\n")
end

if size(qTokens, 'r') > 1 then // question has more than one word
    printf("\n")
    printf("Documents that answer the conjunctive request:")
    disp(documentsAnd)
    for i=1:n
        if documentsAnd(i) == 1 then
            printf("Documento %d\n", i)
        end
    end
    
    printf("\n")
    printf("Documents that answer the disjunctive request:")
    disp(documentsOr)
    for i=1:n
        if documentsOr(i) == 1 then
            printf("Documento %d\n", i)
        end
    end
else // question has only one word
    printf("\n")
    printf("Documents that answer the request:")
    disp(documentsAnd)
    for i=1:n
        if documentsAnd(i) == 1 then
            printf("Documento %d\n", i)
        end
    end
end
