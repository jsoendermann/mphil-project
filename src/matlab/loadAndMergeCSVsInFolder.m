files = dir('*.csv');
D = false;
for f = files'
    Ds = csvread(f.name, 1);
    if ~D
        D = Ds;
    else
        D = [D; Ds];
    end
end