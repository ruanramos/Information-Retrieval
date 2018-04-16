// Ruan da Fonseca Ramos
// Modelo booleano: Matriz de incidência com contagem de frequência
// update 1: adicionado contagem de peso usando sistema TF-IDF

// documents matrix, already stemmized
M=['O peã e o caval são pec de xadrez. O caval é o melhor do jog.';
'A jog envolv a torr, o peã e o rei.';
'O peã lac o boi';
'Caval de rodei!';
'Polic o jog no xadrez.';
'caval caval caval caval';
'O rat roe roup do rei de roma que era xadrez com um caval';
'O menin jog o caval pela janel']

stopwords=['a'; 'o'; 'e'; 'é'; 'de'; 'do'; 'no'; 'são']

// the search, already stemmized and suposing you only make questions with
// words that are on the index or it get's ignored
q='jog xadrez';

// separators for getting the tokens
separators=[' ';',';'.';'!';'?'; '('; ')']

// normalizing the text
M = convstr(M,"l")
q = convstr(q,"l")
stopwords = convstr(stopwords,"l")

// getting the tokens from the documents
myTokens = []
numberOfDocuments = size(M, 'r') // number of documents
for i=1:numberOfDocuments
    myTokens = [myTokens; tokens(M(i), separators)]
end

// removing the stopwords from the tokens list
// this step is already taking care of removing the stopwords from the document
// and from the incidence matrix that we will create
numberOfStopwords = size(stopwords, 'r')
for i=1:numberOfStopwords
    [row] = find(myTokens == stopwords(i))
    myTokens(row,:) = []
end

// removing the stopwords from the search
qTokens = tokens(q, [separators])
sizeq = size(qTokens, 'r')
for i=1:numberOfStopwords
    [row] = find(qTokens == stopwords(i))
    qTokens(row,:) = []
end

// remove repeated tokens
myTokens = unique(myTokens)

// construct the incidence matrix using the M matrix of documents and the tokens
numberTokens = size(myTokens, 'r')
incidenceMatrix = zeros(numberTokens, numberOfDocuments)
apearences = 0
for i=1:numberTokens
    for j=1:numberOfDocuments
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
    for j=1:numberOfDocuments
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
printf("\n--------------------------------INCIDENCE MATRIX--------------------------------\n")
for i=1:numberTokens
    printf('%s\t\t\t', myTokens(i))
    for j=1:numberOfDocuments
        printf('%d', incidenceMatrix(i,j))
    end
    printf("\n")
end

if size(qTokens, 'r') > 1 then // question has more than one word
    printf("\n")
    printf("Documents that answer the conjunctive request:")
    disp(documentsAnd)
    for i=1:numberOfDocuments
        if documentsAnd(i) == 1 then
            printf("Documento %d\n", i)
        end
    end
    
    printf("\n")
    printf("Documents that answer the disjunctive request:")
    disp(documentsOr)
    for i=1:numberOfDocuments
        if documentsOr(i) == 1 then
            printf("Documento %d\n", i)
        end
    end
else // question has only one word
    printf("\n")
    printf("Documents that answer the request:")
    disp(documentsAnd)
    for i=1:numberOfDocuments
        if documentsAnd(i) == 1 then
            printf("Documento %d\n", i)
        end
    end
end

printf("\n-----------------------------TF-IDF PONDERATION MATRIX--------------------------------\n")

// implementing the TF-IDF ponderation scheme
// using log as log to base 2
// For the terms on the docs: wi,j = (1 + log(fi,j)) * log(N/ni)
// For the terms on the question: wi,j = (1 + log(fi,q)) * log(N/ni)
// wi,j = final value of the term; N = total number of documents;
// fi,j = frequency of term i on document j; fi,q = frequency of term i on question q;
// ni = number of documents that have the term i


// now we create the ponderation matrix and calculate each ponderation wi,j
ponderationMatrix = incidenceMatrix
w = 0
for i=1:numberTokens
    printf('%s\t\t', myTokens(i))
    // calculating ni for each term ki
    documentFrequency = 0
    for j=1:numberOfDocuments
        if incidenceMatrix(i,j) > 0 then
            documentFrequency = documentFrequency + 1
        end
    end
    // calculating wi,j for each term ki and document dj
    for j=1:numberOfDocuments
        if incidenceMatrix(i,j) > 0 then
            w = ((log2(incidenceMatrix(i,j))) + 1 ) * (log2(numberOfDocuments / documentFrequency))
        else
            w = 0
        end
        ponderationMatrix(i,j) = w
        // printing the ponderation matrix
        printf('%.4f  ', ponderationMatrix(i,j))
    end
    printf("\n")
end
