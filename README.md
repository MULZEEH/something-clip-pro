# something-clip-pro
 CROSS-LINKING idea:
 PureCLIP looks for the "exact start " position of the reads to map the binding site
 since cross-linking can occur anywhere the protein contacts the RNA, the "size" of the binding site is the genomic interval where cross-link evcents are significantly higher than the background "noise" of random collisions.

1) to infer the size of the binding: uses KERNEL DENSITY ESTIMTION (a non-parametric method to estimate the probability density function of a random variable)
the ide ais to exploita Gaussian curbve over every single-nucleotide cross-link site (SNCLS) that defines a "landscape" distribution
 since the computatioion of KDE might take a while thinking of switching to something more computational pragmatic/easier to parallelize suhc as C or RUst
2) inferred the binding site size we need to pass to the statistical validation of each peak found. 
 using a Permutation Test (NUll Model) -> considering the interval of confidence of 95% of the peak, generate Null Distribution with shuffles and the things u usually do, and calculate the p-value on the same positionby chance
2.1) could alsto analyze the entropy of the peak size as a validation method
probabily using the nurmnal kernel for the KDE
 where teta is the standard normal density function. The kernel density estimator then becomes

{\displaystyle {\hat {f}}_{h}(x)={\frac {1}{n}}\sum _{i=1}^{n}{\frac {1}{h{\sqrt {2\pi }}}}\exp \left({\frac {-(x-x_{i})^{2}}{2h^{2}}}\right),}

### TODO:
add base environment for snake and also others for pureclip and such
statistical testing
find out what the pipeline whants
