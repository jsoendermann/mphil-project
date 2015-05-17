import flowchart;

void drawIteration(int nr) {
block data1=roundrectangle("Dataset",(nr*9cm,0));
block algo1=rectangle(pack(Label("Learning"), Label("algorithm")), (nr*9cm, 3cm));
block appr1=rectangle(pack(Label("Approximation"), Label("parameters")), (nr*9cm-4cm,3cm), drawpen=white);
block out1=rectangle("Performance", (nr*9cm,6cm), drawpen=white);
label("Iteration " + (string)(nr+1), (nr*9cm,-2cm));

draw(data1);
draw(appr1);
draw(algo1);
if (nr != 1)
    draw(out1);

add(new void(picture pic, transform t) {
    blockconnector operator --=blockconnector(pic,t);
    
    data1--Arrow--algo1;
    appr1--Arrow--algo1;
    algo1--Arrow--out1;
});
}

drawIteration(0);
drawIteration(1);
drawIteration(2);

string repstring(string s, int c) {
    string out = "";
    for (int i = 0; i < c; i+=1) {
        out += s;
    }
    return out;
}

block perfData=roundrectangle(Label(repstring("\ ", 65) + "Performance" + repstring("\ ", 65)), (9cm,6cm));
block gp=rectangle("Gaussian Process", (9cm, 9cm));
block hyps=rectangle(pack(Label("Sampled/optimised"), Label("hyperparameters")), (4cm, 9cm), drawpen=white);

block scheduler=rectangle("Scheduler", (22.5cm, 9cm));

block data1=roundrectangle("Dataset",(3*9cm,0));
block algo1=rectangle(pack(Label("Learning"), Label("algorithm")), (3*9cm, 3cm));
label("Next iteration", (3*9cm,-2cm));

//block nextappr=rectangle(pack(align=W,Label("Select"), Label("approximation"), Label("parameters")), (24cm,2.5cm), drawpen=white);

label("Select", (22.45cm, 6.5cm), E);
label("approximation", (22.45cm, 6cm), E);
label("parameters", (22.45cm, 5.5cm), E);


draw(perfData);
draw(gp);
draw(hyps);
draw(scheduler);
draw(data1);
draw(algo1);
//draw(nextappr);


add(new void(picture pic, transform t) {
    blockconnector operator --=blockconnector(pic,t);
    
    perfData--Arrow--gp;
    hyps--Arrow--gp;
    gp--Label("Performance predictions",0.5,N)--Arrow--scheduler;
    data1--Arrow--algo1;
    scheduler--Down--Right--Arrow--algo1;
});


