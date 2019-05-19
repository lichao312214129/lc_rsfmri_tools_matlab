function cov=lc_load_cov(path)
try
    cov = importdata(path);
catch
    cov = xlsread(path);
end
end