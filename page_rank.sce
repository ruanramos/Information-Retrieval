// PageRank

// PR(alpha) = (1 - B) / T + B * sum( PR(pi) / L(pi) ) for all i = 1 .. n
// L(pi) = number of outlinks of the page pi

// n = number of nodes or pages
n = 4

// initial value for each pagerank
a = 1/n
b = 1/n
c = 1/n
d = 1/n
r = [a;b;c;d]

// threshold value
threshold = 0.0001

// Beta value (probability of teleportation)
B = 0.8

// stop = 1 says we stop the iteration
stop = 0

// calculating the initial matrix
/*
a = c
b = a / 2
c = a / 2 + b + d
*/

M = [0, 0, 1, 0; 
1/2, 0, 0, 0;
1/2, 1, 0, 1;
0, 0, 0, 0]

M2 = [1/n, 1/n, 1/n, 1/n;
1/n, 1/n, 1/n, 1/n;
1/n, 1/n, 1/n, 1/n;
1/n, 1/n, 1/n, 1/n]

Mfinal = 0.8 * M + 0.2 * M2
t = r

while stop == 0
    disp(r)
    rtmp = r
    r = Mfinal * r
    if (abs(r(1) - rtmp(1)) <= threshold) & (abs(r(2) - rtmp(2)) <= threshold) & (abs(r(3) - rtmp(3)) <= threshold) & (abs(r(4) - rtmp(4)) <= threshold) then
        stop = 1
    end
end
printf("Rank of page A: %f\n", r(1))
printf("Rank of page B: %f\n", r(2))
printf("Rank of page C: %f\n", r(3))
printf("Rank of page D: %f\n", r(4))
