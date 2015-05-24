real u = 1cm;

void drawBox(string s, pair p, real w, real h, bool bg=false, pen bgcolor=white, pen content=black) {
    label(s, p, content);

    path box = (p.x-w/2, p.y-h/2)--(p.x+w/2, p.y-h/2)--(p.x+w/2, p.y+h/2)--(p.x-w/2, p.y+h/2)--cycle;

    if (bg)
        fill(box, bgcolor);

    draw(box, content);
}

void drawAlgo(string algo, pair p) {
    drawBox("Learn", p, 2u, 1u);
    add(pack(Label("Algorithm " + algo)), (p.x-3u, p.y+0.75u));
    add(pack(Label("Approximation"), Label("parameters")), (p.x-3u, p.y-0.75u));

    draw((p.x-3u, p.y+0.4u)--(p.x-3u, p.y+0.15u)--(p.x-1u, p.y+0.15u), EndArrow);
    draw((p.x-3u, p.y-0.4u)--(p.x-3u, p.y-0.15u)--(p.x-1u, p.y-0.15u), EndArrow);
}

drawBox("Dataset", (0,0), 3u, 1u, true, green+white+white);
drawAlgo("A", (-7u,3u));
drawAlgo("A", (0,3u));
drawAlgo("B", (7u,3u));
draw((-0.35u,0.5u)--(-0.35u, 1u)--(-7u,1u)--(-7u,2.5u), EndArrow);
draw((0,0.5u)--(0,2.5u), EndArrow);
draw((0.35u,0.5u)--(0.35u, 1.35u)--(7u,1.35u)--(7u,2.5u), EndArrow);
draw((0.7u,0.5u)--(0.7u, 1u)--(14u,1u)--(14u,2.5u), grey, EndArrow);

// time/score datasets
real yTime = 8.5u;
real yScore = 7u;
drawBox("", (0.5u,yScore), 17u,1u, true, green+white+white);
drawBox("", (-0.5u,yTime), 17u,1u, true, green+white+white);
label("Time", (3u,yTime));
label("Score", (3u,yScore));


// algo to time/score
draw((-7.15u,3.5u)--(-7.15u,yTime-0.5u), EndArrow);
draw((-6.85u,3.5u)--(-6.85u,yScore-0.5u), EndArrow);

draw((-0.15u,3.5u)--(-0.15u,yTime-0.5u), EndArrow);
draw((0.15u,3.5u)--(0.15u,yScore-0.5u), EndArrow);

draw((6.85u,3.5u)--(6.85u,yTime-0.5u), EndArrow);
draw((7.15u,3.5u)--(7.15u,yScore-0.5u), EndArrow);


// gps
real yGP1 = 12.5u;
real yGP2 = 11u;
drawBox("Gaussian process", (0,yGP1), 3.75u, 1u);
drawBox("Gaussian process", (0,yGP2), 3.75u, 1u);
draw((-3.25u,yTime+0.5u)--(-3.25u,yGP1)--(-1.875u,yGP1), EndArrow);
draw((-2.75u,yScore+0.5u)--(-2.75u,yGP2)--(-1.875u,yGP2), EndArrow);


// scheduler
drawBox("Scheduler", (7u, 11.75u), 2.5u, 1u);
draw((1.875u,yGP1)--(2.5u,yGP1)--(2.5u,11.9u)--(5.75u,11.9u), EndArrow);
draw((1.875u,yGP2)--(2.5u,yGP2)--(2.5u,11.6u)--(5.75u,11.6u), EndArrow);

drawBox("Learn", (14u, 3u), 2u, 1u, false, white, grey);
draw((14u,3.5u)--(14u,6.5u), grey, EndArrow);
label("$\cdots$", (14u,6.75u), grey);


draw((8.25u, 11.9u)--(10.5u, 11.9u)--(10.5u,3.15u)--(13u,3.15u), EndArrow);
draw((8.25u, 11.6u)--(10.2u, 11.6u)--(10.2u,2.85u)--(13u,2.85u), EndArrow);

//add(pack(Label("Approximation"), Label("parameters")), (9u, 10u));
label("Approximation", (10.2u,10.2u), W);
label("parameters", (10.2u,9.8u), W);
label("Algorithm", (10.5u, 10u), E);




// tiers
draw((-14u,-1u)--(16u,-1u), gray);
draw((-14u,5u)--(16u,5u), gray); 
label("{\huge Tier 1}", (-14u,5u), SE);
label("{\huge Tier 2}", (-14u,13u), SE);

label("Iteration $n$", (-7u,-2u));
label("Iteration $n+1$", (0u,-2u));
label("Iteration $n+2$", (7u,-2u));
label("Iteration $n+3$", (14u,-2u),grey);

void drawNumber(string n, pair p) {
    draw(shift(p)*scale(0.3u)*unitcircle, linewidth(2));
    label("\textbf{"+n+"}", p);
}

drawNumber("1", (-2u,0u));
drawNumber("2", (-11.5u,3u));
drawNumber("3", (-8.75u,7.25u));
drawNumber("4", (-4u,11.75u));
drawNumber("5", (7u,13u));
drawNumber("6", (11.5u,11u));
drawNumber("7", (13u,4u));
