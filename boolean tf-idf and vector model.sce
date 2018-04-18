// Ruan da Fonseca Ramos
// Modelo booleano: Matriz de incidência com contagem de frequência (documentos e pesquisa)
// update 1: adicionado contagem de peso para os termos usando sistema TF-IDF (documentos e pesquisa)
// update 2: adicionado modelo vetorial com rankeamento (18/04/2018)

// documents matrix, already stemmized
M=['O peã e o caval são pec de xadrez. O caval é o melhor do jog.';
'A jog envolv a torr, o peã e o rei.';
'O peã lac o boi';
'Caval de rodei!';
'Polic o jog no xadrez.']
//'caval caval caval caval';
//'O rat roe roup do rei de roma que era xadrez com um caval';
//'O menin jog o caval pela janel']

stopwords=['a'; 'o'; 'e'; 'é'; 'de'; 'do'; 'no'; 'são']

// the search, already stemmized and suposing you only make questions with
// words that are on the index or it get's ignored
q='boi xadrez';

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

// construct the incidence matrix of documents using the M matrix of documents and the tokens
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
        incidenceMatrix(i,j) = apearences
        apearences = 0
    end
    j = 1 
end

// construct the incidence matrix of the search using the M matrix of documents and the tokens
searchIncidenceMatrix = zeros(numberTokens, 1)
apearences = 0
searchTokens = tokens(q , separators) // search tokens
for i=1:numberTokens
    for j=1:size(searchTokens,'r')
        if myTokens(i) == searchTokens(j) then
            apearences = apearences + 1
        end
     end
    searchIncidenceMatrix(i,1) = apearences
    apearences = 0
j = 1 
end

// ----------------- BOOLEAN MODEL START --------------------

// getting the rows of the incidence matrix we will need for boolean model
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

// here we make the bit operations of the boolean model
documentsAnd = rows(1,:)
documentsOr = rows(1,:)

for i=2:size(rows, 'r')
    documentsAnd = bitand(documentsAnd, rows(i,:))
end
for i=2:size(rows, 'r')
    documentsOr = bitor(documentsOr, rows(i,:))
end


// ----------------- BOOLEAN MODEL END --------------------

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

// implementing the TF-IDF ponderation scheme
// using log as log to base 2
// For the terms on the docs: wi,j = (1 + log(fi,j)) * log(N/ni)
// For the terms on the question: wi,q = (1 + log(fi,q)) * log(N/ni)
// wi,j = final value of the term; N = total number of documents;
// fi,j = frequency of term i on document j; fi,q = frequency of term i on question q;
// ni = number of documents that have the term i

printf("\n-------------------------TF-IDF PONDERATION MATRIX FOR THE DOCUMENTS---------------------------\n")

// now we create the ponderation matrix for the documents and calculate each ponderation wi,j
ponderationMatrixDocuments = incidenceMatrix
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
        ponderationMatrixDocuments(i,j) = w
        // printing the ponderation matrix
        printf('%.4f  ', ponderationMatrixDocuments(i,j))
    end
    printf("\n")
end

printf("\n-------------------------TF-IDF PONDERATION MATRIX FOR THE SEARCH---------------------------\n")

ponderationMatrixSearch = searchIncidenceMatrix
wq = 0
for i=1:numberTokens
    printf('%s\t\t', myTokens(i))
    // calculating ni for each term ki
    searchFrequency = 0
    if searchIncidenceMatrix(i,1) > 0 then
        searchFrequency = searchFrequency + 1
    end
    // calculating wi,q for each term ki
    if searchIncidenceMatrix(i,1) > 0 then
        wq = ((log2(searchIncidenceMatrix(i,1))) + 1 ) * (log2(numberOfDocuments / searchFrequency))
    else
        wq = 0
    end
    ponderationMatrixSearch(i,1) = wq
    // printing the ponderation matrix
    printf('%.4f  ', ponderationMatrixSearch(i,1))
    printf("\n")
end

// ----------------- VECTOR SPACE MODEL START --------------------

// we will now calculate the ranking of each document given the question q using vector space model
// we use the notations as below:
// q = (w1,q , w2,q , w3,q , ... , wm,q) --> q is the vector of ponderations of each term in the search
// dj = (w1,j , w2,j , w3,j , ... wn,j) --> dj is the vector of ponderations of each term in the document j
// we also normalize the vectors so big and small documents are made "more equal"

// calculating the norm of the q vector and saving at normq
normq = 0
for i=1:size(ponderationMatrixSearch, 'r')
    normq = normq + ponderationMatrixSearch(i,1)^2
end
normq = sqrt(normq)

// calculating the norm of the vectors dj and saving it at normdj
normdj = zeros(numberOfDocuments, 1)
for i=1:numberOfDocuments
    for j=1:numberTokens
       normdj(i,1) = normdj(i,1) + ponderationMatrixDocuments(j,i)^2
    end
    normdj(i,1) = sqrt(normdj(i,1))
end

// calculating the ranks of the documents
// sim(dj, q) = (dj . q) / ( norm(dj) x norm(q) )
rankedDocuments = zeros(numberOfDocuments, 1)
for i=1:numberOfDocuments
    for j=1:numberTokens
       if ponderationMatrixSearch(j,1) ~= 0 || ponderationMatrixDocuments(j,1) ~= 0 then
           rankedDocuments(i,1) = rankedDocuments(i,1) + ponderationMatrixSearch(j,1) * ponderationMatrixDocuments(j,i)
       end
    end
    rankedDocuments(i,1) = rankedDocuments(i,1) / (normdj(i,1) * normq)
end

// now we have stored at the variable rankedDocuments the rankings of the documents of interest
// we need to sort it and show it on the screen

sortedRankedDocuments = gsort(rankedDocuments)
documentsIndexes = []
for i=1:numberOfDocuments
    for j=1:numberOfDocuments
       if (rankedDocuments(j) == sortedRankedDocuments(i)) & (rankedDocuments(j) ~= 0) then
           documentsIndexes = [documentsIndexes; j]
       end
    end
end

// now showing on screen
printf("\n---------------------RANKED DOCUMENTS FOR YOUR SEARCH (VECTOR SPACE MODEL)---------------------\n\n")
printf("______________________________________________________\n\n")
printf("Your search was: ")
printf("   %s\n\n", q)
printf("Were found %d results of interest\n\n", size(documentsIndexes, 'r'))
printf("______________________________________________________\n\n")

for i=1:size(documentsIndexes, 'r')
    printf("RANK: %f \t\t DOCUMENT NUMBER: %d \n\n", sortedRankedDocuments(i), documentsIndexes(i))
    printf("%s", M(documentsIndexes(i)))
    printf("\n\n")
    printf("______________________________________________________\n\n")
end

// ----------------- VECTOR SPACE MODEL END --------------------
