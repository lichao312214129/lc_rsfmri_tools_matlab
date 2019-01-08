function cov=load_cov(path)
try
    cov=importdata(path);
catch
    cov=xlsread(path);
end
end