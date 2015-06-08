real u = 1.5cm;

// x
draw((-.25u,0)--(3.5u,0), Arrow);
// y
draw((0,-.1u)--(0,1.5u), Arrow);

// (sin(2*pi*x)+1)/2 from 0 to 3
real Sin(real t) {return (sin(2pi*t/1u)+1)/2;}
path f = (0,u*Sin(0))..(0.1,u*Sin(0.1));

for (real x = 0.2; x <= 3u; x = x + 0.1) {
    f = f..(x,u*Sin(x));
}

draw(f);


draw((1.3u,0)--(1.3u,0.7u));
draw((1.3u,0.7u)--(1.3u,0.9756u), gray(0.8));

dot((1.3u,0.9756u));
label("$y$", (1.3u,0.9756u), NE);
label("$u$", (-0.05u,0.7u), W);
draw((-0.05u,0.7u)--(0.05u,0.7u));

draw((0.6u,0.7u)--(1.0655u,0.7u), dashed);
draw((1.0655u,0.7u)--(1.4345u,0.7u));
draw((1.4345u,0.7u)--(2.0655u,0.7u), dashed);
draw((2.0655u,0.7u)--(2.4u,0.7u));


dot((1.3u,0));
label("$x$", (1.3u,-0.05u), S);

draw((0.6u,0.65u)--(0.6u,0.75u));
label("$x_l$", (0.6u,-0.05u), S);

draw((2.4u,0.65u)--(2.4u,0.75u));
label("$x_r$", (2.4u,-0.05u), S);

dot((1.7u,0.7u));
label("$x'$", (1.7u,0.03u), S);
