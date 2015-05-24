import flowchart;

real u = 0.9*cm;



/*block algo=rectangle(pack(Label("Learning"), Label("algorithm")), (0,0));*/
/*block f=rectangle(Label("$\hat{f}$"), (0,-3u));*/
/*block train=roundrectangle(pack(Label("Training"), Label("data")), (0, 3u));*/
/*block hyps=rectangle("Hyperparameters", (-4u,0), drawpen=white);*/
/*block fresh=roundrectangle(pack(Label("Unseen"), Label("data")), (-4u, -3u));*/
/*block pred=roundrectangle("Predictions", (4u, -3u));*/

/*draw(algo);*/
/*draw(f);*/
/*draw(train);*/
/*draw(hyps);*/
/*draw(fresh);*/
/*draw(pred);*/

/*add(new void(picture pic, transform t) {*/
        /*blockconnector operator --=blockconnector(pic,t);*/
        
        /*algo--Arrow--f;*/
        /*train--Arrow--algo;*/
        /*hyps--Arrow--algo;*/
        /*fresh--Arrow--f;*/
        /*f--Arrow--pred;*/
        /*[>data1--Arrow--algo1;<]*/
        /*[>appr1--Arrow--algo1;<]*/
        /*[>algo1--Arrow--out1;<]*/
    /*});*/

/*[>real ITER_DIST = 7.5*u;<]*/
/*[>int N_SPACES = 55;<]*/
/*[>real PERF_Y = 7.5u;<]*/


/*[>void drawIteration(int iter) {<]*/
    /*[>block data1=roundrectangle("Dataset",(iter*ITER_DIST,0),fillpen=red+white+white);<]*/
    /*[>block algo1=rectangle(pack(Label("Learning"), Label("algorithm")), (iter*ITER_DIST, 3*u),fillpen=blue+white+white);<]*/
    /*[>block appr1=rectangle(pack(Label("Approximation"), Label("parameters")), (iter*ITER_DIST-4*u,3*u), drawpen=white);<]*/
    /*[>block out1=rectangle("Performance", (iter*ITER_DIST,PERF_Y), drawpen=white);<]*/
    /*[>label("Iteration " + (string)(iter+1), (iter*ITER_DIST,-2*u));<]*/

    /*[>draw(data1);<]*/
    /*[>draw(appr1);<]*/
    /*[>draw(algo1);<]*/
    /*[>if (iter != 1)<]*/
        /*[>draw(out1);<]*/

    /*[>add(new void(picture pic, transform t) {<]*/
        /*[>blockconnector operator --=blockconnector(pic,t);<]*/
        
        /*[>data1--Arrow--algo1;<]*/
        /*[>appr1--Arrow--algo1;<]*/
        /*[>algo1--Arrow--out1;<]*/
    /*[>});<]*/
/*[>}<]*/

/*[>drawIteration(0);<]*/
/*[>drawIteration(1);<]*/
/*[>drawIteration(2);<]*/

/*[>string repstring(string s, int c) {<]*/
    /*[>string out = "";<]*/
    /*[>for (int i = 0; i < c; i+=1) {<]*/
        /*[>out += s;<]*/
    /*[>}<]*/
    /*[>return out;<]*/
/*[>}<]*/

/*[>block perfData=roundrectangle(Label(repstring("\ ", N_SPACES) + "Performance" + repstring("\ ", N_SPACES)), (ITER_DIST,PERF_Y), fillpen=red+white+white);<]*/
/*[>block gp=rectangle("Gaussian Process", (ITER_DIST, 10*u),fillpen=blue+white+white);<]*/
/*[>block hyps=rectangle(pack(Label("Sampled/optimised"), Label("hyperparameters")), (2*u, 10*u), drawpen=white);<]*/

/*[>block scheduler=rectangle("Scheduler", (2.5*ITER_DIST, 10*u),minwidth=3u,minheight=1.5u);<]*/

/*[>block data1=roundrectangle(Label("Dataset", gray),(3*ITER_DIST,0), drawpen=gray);<]*/
/*[>block algo1=rectangle(pack(Label("Learning", gray), Label("algorithm", gray)), (3*ITER_DIST, 3*u), drawpen=gray);<]*/
/*[>label("Next iteration", (3*ITER_DIST,-2*u), gray);<]*/

/*[>//block nextappr=rectangle(pack(align=W,Label("Select"), Label("approximation"), Label("parameters")), (24*u,2.5*u), drawpen=white);<]*/

/*[>label("Select", (2.5*ITER_DIST, PERF_Y+0.5u), E);<]*/
/*[>label("approximation", (2.5*ITER_DIST, PERF_Y), E);<]*/
/*[>label("parameters", (2.5*ITER_DIST, PERF_Y-0.5u), E);<]*/


/*[>draw(perfData);<]*/
/*[>draw(gp);<]*/
/*[>draw(hyps);<]*/
/*[>draw(scheduler);<]*/
/*[>draw(data1);<]*/
/*[>draw(algo1);<]*/
/*[>//draw(nextappr);<]*/


/*[>add(new void(picture pic, transform t) {<]*/
    /*[>blockconnector operator --=blockconnector(pic,t);<]*/
    
    /*[>perfData--Arrow--gp;<]*/
    /*[>hyps--Arrow--gp;<]*/
    /*[>gp--Label("Performance predictions",0.5,N)--Arrow--scheduler;<]*/
    
    /*[>scheduler--Down--Right--Arrow--algo1;<]*/

/*[>});<]*/

/*[>add(new void(picture pic, transform t) {<]*/
    /*[>blockconnector operator --=blockconnector(pic,t,gray);<]*/
    

    /*[>data1--Arrow--algo1;<]*/
/*[>});<]*/

/*[>draw((-6u,-1.25u)--(24u,-1.25u), gray);<]*/
/*[>draw((-6u,5.5u)--(24u,5.5u), gray);<]*/

/*[>label(scale(1.75)*Label("Tier 1"), (-6u,5.25u), SE);<]*/
/*[>label(scale(1.75)*Label("Tier 2"), (-6u,10.75u), SE);<]*/
